param (
	[Parameter(Mandatory=$false)]
    [string]$VBoxManagePath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe",
	
	[Parameter(Mandatory=$false)]
    [ValidateSet('start', 'stop')]
    [string]$Action = "start",  # 기본값은 'start' (가상 머신 시작)
	
	[string]$Pattern = "kafka"
)

# 가상 머신 리스트 가져오기 함수
function Get-VMList {
    $vms = & $VBoxManagePath list vms | Where-Object { $_ -like "*$Pattern*" }
    return $vms
}

# 실행 중인 가상 머신 리스트 가져오기 함수
function Get-RunningVMList {
    $runningVMs = & $VBoxManagePath list runningvms
    return $runningVMs
}

# 가상 머신을 헤드리스 모드로 시작하는 함수
function Start-VM {
    param ($vmName)
    & $VBoxManagePath startvm $vmName --type headless
}

# 가상 머신을 종료하는 함수
function Stop-VM {
    param ($vmName)
    & $VBoxManagePath controlvm $vmName acpipowerbutton
}

# 비동기적으로 가상 머신을 시작하는 함수
function Start-VirtualMachinesAsync {
    # 모든 가상 머신 리스트 가져오기
    $vms = Get-VMList

    # 각 가상 머신을 비동기적으로 실행
    foreach ($vm in $vms) {
        $vmName = ($vm -split ' ')[0].Trim('"')
		
		$vmStatusLine = & $VBoxManagePath showvminfo $vmName --machinereadable | Where-Object { $_ -match "^VMState=" }
		$vmStatus = ($vmStatusLine -split "=")[1].Trim('"')
		
		# 실행중이면 굳이 다시 실행할 필요가 없다.
		# 물론 vm 자체에서 거부하긴 하겠지만...
		if ($vmStatus -ne "running") {
			Start-Job -ScriptBlock {
				param($VBoxManagePath, $vmName)
				& $VBoxManagePath startvm $vmName --type headless
			} -ArgumentList $VBoxManagePath, $vmName
		}
    }

    # 모든 백그라운드 작업이 완료될 때까지 기다리기
    Get-Job | ForEach-Object {
		Wait-Job -Job $_
		Remove-Job -Job $_
	}
}

# 비동기적으로 가상 머신을 종료하는 함수
function Stop-VirtualMachinesAsync {
    # 실행 중인 가상 머신 리스트 가져오기
    $runningVMs = Get-RunningVMList

    # 각 실행 중인 가상 머신을 비동기적으로 종료
    foreach ($vm in $runningVMs) {
        $vmName = ($vm -split ' ')[0].Trim('"')
        Start-Job -ScriptBlock {
            param($VBoxManagePath, $vmName)
            & $VBoxManagePath controlvm $vmName acpipowerbutton
        } -ArgumentList $VBoxManagePath, $vmName
    }

    # 모든 백그라운드 작업이 완료될 때까지 기다리기
    Get-Job | ForEach-Object {
		Wait-Job -Job $_
		Remove-Job -Job $_
	}
}

# 주어진 Action에 따라 작업을 실행
try {
    switch ($Action) {
        'start' { Start-VirtualMachinesAsync }
        'stop' { Stop-VirtualMachinesAsync }
        default { Write-Host "잘못된 Action 값입니다. 'start' 또는 'stop'을 입력하세요."; exit 1 }
    }
}
catch {
    Write-Error "스크립트 실행 중 오류가 발생했습니다:`n$($_.Exception.Message)"
    exit 1
}