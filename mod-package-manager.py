# WARNING! This script works but the package manager of your choice might not containt the packages that we install. 
# You WILL get many "Package not found" errors, so be prepared to use external resources. This is not a self sufficient script.



#replace every instacnce in the installer file where apt is found.
def replace_package_manager_in_file(input_file_path, output_file_path, old_pm, new_pm):
    try:
        with open(input_file_path, 'r') as input_file:
            content = input_file.read()

        updated_content = content.replace(old_pm, new_pm)
        with open(output_file_path, 'w') as output_file:
            output_file.write(updated_content)

        print("Operation succesfull!")
    # This should be incredibly rare, because it is fully specified, still handling it
    except FileNotFoundError:
        print("File not found, please try again")
    except Exception as e:
        print("Error" + str(e))


def main():
    #Initialize variables wtih base tools file, Output name is unimportant, so you can change it
    input_file_path = "tools-maasec.sh"
    output_file_path = "custom-pm-tools-maasec.sh"
    #Use a space before and after apt to not cause errors if "apt" is a substring of a package
    old_pm = " apt "
    # Add a space before and after the input given to not cause formatting errors
    new_pm = " " + input("What packacge manager do you want to use?") + " "
    replace_package_manager_in_file(input_file_path, output_file_path, old_pm, new_pm)
    

if __name__ == "__main__":
    main()
