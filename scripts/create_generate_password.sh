#!/bin/bash
# This script uses a Python script to generate a hashed password using bcrypt.

vim generate_password.py <<EOL
import getpass
import bcrypt

# Step 2: Prompt the user for a password
password = getpass.getpass("password: ")

# Step 3: Generate a hashed password using bcrypt
hashed_password = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt())

# Step 4: Print the hashed password
print(hashed_password.decode())
EOL
