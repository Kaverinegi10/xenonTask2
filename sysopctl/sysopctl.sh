#!/bin/bash

if [[ $# == 0 ]]; then
    echo "Error: Provide arguments"
    exit 1
else
    case "$1" in
        --version)
            echo "The current version is 6.9"
            exit 0
            ;;./sysopctl.sh cpu


        --help)
            echo -e "
            cpu get info           To get details about the CPU
            memory get info        To get details about the memory
            user                   To perform user operations
                                    create <USER> - To add a user to the system
                                    [Options]
                                        list   - To get all the users added to the system
                                        [Options]
                                            --sudo-only flag to filter users with sudo access
            file                   To perform actions on files
                                    [Options]
                                        getinfo <FILE-NAME> - To get details about a file
                                            --size, -s to print size
                                            --permissions, -p print file permissions
                                            --owner, -o print file owner
                                            --last-modified, -m print last modified timestamp
            "
            ;;

        "cpu")
            lscpu | grep "^Architecture"
            lscpu | grep "^CPU op-mode(s)"
            lscpu | grep -a7 "Vendor ID"
            ;;

        "memory")
            echo "Memory commands go here"
            ;;

        "user")
            case $2 in
                create)
                    useradd -s /bin/bash -m "$3"
                    ;;

                list)
                    if [[ $3 == "--sudo-only" ]]; then
                        sudo_users=$(getent group sudo | cut -d: -f4 | tr ',' '\n')
                        if [[ -z "$sudo_users" ]]; then
                            echo "There are no users in the sudoers group"
                        else
                            echo "$sudo_users"
                        fi
                    else
                        cut -d: -f1 /etc/passwd
                    fi
                    ;;

                *)
                    echo "Invalid flags"
                    ;;
            esac
            ;;

        "file")
            case $2 in
                getinfo)
                    shift
                    case $2 in
                        --size)
                            du "$3"
                            ;;
                        --permissions)
                            ls -l "$3" | awk '{ print $1 }'
                            ;;
                        --owner)
                            ls -l "$3" | awk '{ print $3 }'
                            ;;
                        --last-modified)
                            stat "$3" | grep "Modify" | awk -F'[:.]' '{ print $2 }'
                            ;;
                        *)
                            file_details=$(ls -l "$2")
                            echo "
                                  File        $2
                                  Access:     $(echo "$file_details" | awk '{ print $1 }')
                                  Size:       $(du "$2" | awk '{ print $1 }')
                                  Owner:      $(echo "$file_details" | awk '{ print $3 }')
                                  Modify:     $(stat "$2" | grep "Modify" | awk -F'[:.]' '{ print $2 }')
                                "
                            ;;
                    esac
                    ;;
                *)
                    echo "Invalid file command"
                    ;;
            esac
            ;;

        *)
            echo "Invalid option. Use --version or --help for more information."
            exit 1
            ;;
    esac
fi