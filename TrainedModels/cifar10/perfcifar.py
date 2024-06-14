import subprocess

def run_perf_command(command):
    result = subprocess.run(["perf", "stat"] + command,
                            text=True, capture_output=True)
    return result.stdout

# Example usage
output = run_perf_command(["python3", "valTrain.py"])
print(output)
