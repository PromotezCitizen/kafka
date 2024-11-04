lines = []

with open("normal.txt", "r") as file:
  for line in file:
    trimmed_line = line.strip()
    if trimmed_line:
      lines.append(trimmed_line)


with open("community.txt", "r") as file:
  for line in file:
    trimmed_line = line.strip()
    if trimmed_line:
      lines.remove(trimmed_line)

with open("result.txt", "w") as file:
  file.write("\n".join(lines))