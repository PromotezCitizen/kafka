param (
	[Parameter(Mandatory=$false)]
    [string]$VBoxManagePath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe",
	
	[Parameter(Mandatory=$false)]
    [ValidateSet('start', 'stop')]
    [string]$Action = "start",  # �⺻���� 'start' (���� �ӽ� ����)
	
	[string]$Pattern = "kafka"
)

# ���� �ӽ� ����Ʈ �������� �Լ�
function Get-VMList {
    $vms = & $VBoxManagePath list vms | Where-Object { $_ -like "*$Pattern*" }
    return $vms
}

# ���� ���� ���� �ӽ� ����Ʈ �������� �Լ�
function Get-RunningVMList {
    $runningVMs = & $VBoxManagePath list runningvms
    return $runningVMs
}

# ���� �ӽ��� ��帮�� ���� �����ϴ� �Լ�
function Start-VM {
    param ($vmName)
    & $VBoxManagePath startvm $vmName --type headless
}

# ���� �ӽ��� �����ϴ� �Լ�
function Stop-VM {
    param ($vmName)
    & $VBoxManagePath controlvm $vmName acpipowerbutton
}

# �񵿱������� ���� �ӽ��� �����ϴ� �Լ�
function Start-VirtualMachinesAsync {
    # ��� ���� �ӽ� ����Ʈ ��������
    $vms = Get-VMList

    # �� ���� �ӽ��� �񵿱������� ����
    foreach ($vm in $vms) {
        $vmName = ($vm -split ' ')[0].Trim('"')
		
		$vmStatusLine = & $VBoxManagePath showvminfo $vmName --machinereadable | Where-Object { $_ -match "^VMState=" }
		$vmStatus = ($vmStatusLine -split "=")[1].Trim('"')
		
		# �������̸� ���� �ٽ� ������ �ʿ䰡 ����.
		# ���� vm ��ü���� �ź��ϱ� �ϰ�����...
		if ($vmStatus -ne "running") {
			Start-Job -ScriptBlock {
				param($VBoxManagePath, $vmName)
				& $VBoxManagePath startvm $vmName --type headless
			} -ArgumentList $VBoxManagePath, $vmName
		}
    }

    # ��� ��׶��� �۾��� �Ϸ�� ������ ��ٸ���
    Get-Job | ForEach-Object {
		Wait-Job -Job $_
		Remove-Job -Job $_
	}
}

# �񵿱������� ���� �ӽ��� �����ϴ� �Լ�
function Stop-VirtualMachinesAsync {
    # ���� ���� ���� �ӽ� ����Ʈ ��������
    $runningVMs = Get-RunningVMList

    # �� ���� ���� ���� �ӽ��� �񵿱������� ����
    foreach ($vm in $runningVMs) {
        $vmName = ($vm -split ' ')[0].Trim('"')
        Start-Job -ScriptBlock {
            param($VBoxManagePath, $vmName)
            & $VBoxManagePath controlvm $vmName acpipowerbutton
        } -ArgumentList $VBoxManagePath, $vmName
    }

    # ��� ��׶��� �۾��� �Ϸ�� ������ ��ٸ���
    Get-Job | ForEach-Object {
		Wait-Job -Job $_
		Remove-Job -Job $_
	}
}

# �־��� Action�� ���� �۾��� ����
try {
    switch ($Action) {
        'start' { Start-VirtualMachinesAsync }
        'stop' { Stop-VirtualMachinesAsync }
        default { Write-Host "�߸��� Action ���Դϴ�. 'start' �Ǵ� 'stop'�� �Է��ϼ���."; exit 1 }
    }
}
catch {
    Write-Error "��ũ��Ʈ ���� �� ������ �߻��߽��ϴ�:`n$($_.Exception.Message)"
    exit 1
}