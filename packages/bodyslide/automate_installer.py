import pexpect
import sys

# Get the installer and first argument from the command-line arguments
installer = sys.argv[1]
output_dir = sys.argv[2]

# Start the installer with the provided argument
child = pexpect.spawn(f"{installer} {output_dir}")

# Automate the prompts
child.expect("Agree \\[yes/no\\] ?")
child.sendline("yes")

child.expect("Do you want to read the ReadMe file \\[y/n\\] ?")
child.sendline("n")

# Wait for the process to complete
child.wait()
