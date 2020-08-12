#! /bin/bash

# 临时变量声明
form_size="--height 200 --width 400 "
error_size=" --height 160 --width 320 "
list_size=" --height 640 --width 480 "

# 前向函数声明
function main() {

    while [ 1 ]; do
        mysql_entry=$(zenity --title "Login In Your MySQL" --password --username)

        if [ $? -eq 0 ]; then
            mysql_username=$(echo $mysql_entry | cut -d'|' -f1)
            mysql_password=$(echo $mysql_entry | cut -d'|' -f2)
        else
            exit 0
        fi

        $(mysql -u $mysql_username -p$mysql_password -e ";")

        if [ $? -eq 0 ]; then
            mysql_info=" -u$mysql_username -p$mysql_password"
            mysql_default=" mysql -N HW -u $mysql_username -p$mysql_password "
            break
        else
            Err "Wrong Username or Password" \
                "Cannot connect to your MySQL system. Please try again."
        fi
    done

    Initial

    while [ 1 ]; do

        form=$(yad --form --title "Login As Your Chosen Identity" \
            --text "Enter your account and choose an identity" \
            $form_size --field="Username" --field="Password:H" \
            --field="Identity:CB" '' '' 'Administrator!Teacher!Student')

        if [ -z $form ]; then
            break
        fi

        username=$(echo $form | cut -d'|' -f1)
        password=$(echo $form | cut -d'|' -f2)
        selection=$(echo $form | cut -d'|' -f3)

        case $selection in
        "Administrator")
            LoginAdmin
            ;;

        "Teacher")
            LoginTeacher
            ;;

        "Student")
            LoginStudent
            ;;
        *)
            break
            ;;
        esac
    done

}

function Initial() {
    init_file="$PWD/init.sql"
    if [ -e $init_file ]; then
        mysql -u $mysql_username -p$mysql_password <$init_file

        if [ $? -eq 0 ]; then
            echo "initialization done!"
        else
            Err "Fail to Initialize Database" \
                "Please check your init.sql script."
            exit 1
        fi

    else
        Err "Fail to Initialize Database" \
            "Cannot find file: $init_file"
        exit 1
    fi

}

function LoginAdmin() {

    result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(admin_id) FROM admin WHERE admin_id='$username' AND password='$password'")

    if [ $result -eq 1 ]; then
        echo "successfully login in as administrator"
        DisplayAdminMenu
    else
        Err "Fail to Login in as Administrator" \
            "Wrong matches! Please re-check your username or password"
    fi

}

function LoginTeacher() {
    entry=$(zenity --title "Login As Teacher" --password --username)

    if [ $? -eq 0 ]; then
        admin_username=$(echo $entry | cut -d'|' -f1)
        admin_password=$(echo $entry | cut -d'|' -f2)

        result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(admin_id) FROM admin WHERE admin_id='$admin_username' AND password='$admin_password'")

        if [ $result -eq 1 ]; then
            echo "successfully login in as teacher"
        else
            Err "Fail to Login in as Teacher" \
                "Wrong matches! Please re-check your username or password"
        fi
    fi
}

function LoginStudent() {
    entry=$(zenity --title "Login As Student" --password --username)

    if [ $? -eq 0 ]; then
        student_username=$(echo $entry | cut -d'|' -f1)
        student_password=$(echo $entry | cut -d'|' -f2)

        result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(student_id) FROM student WHERE student_id='$student_username' AND password='$student_password'")

        if [ $result -eq 1 ]; then
            echo "successfully login in as student"
        else
            Err "Fail to Login in as Student" \
                "Wrong matches! Please re-check your username or password"
        fi
    fi
}

function DisplayAdminMenu() {

    while [ 1 ]; do

        selection=$(zenity --list --title "Choose Your Operation" \
            --column "Operation" \
            "Manage Teacher Accounts" \
            "Manage Courses" \
            "Manage Teaching Affairs" \
            "* Back")

        if [ $? -eq 1 ]; then
            break
        fi

        case $selection in
        "Manage Teacher Accounts")
            ManageTeacherAccounts
            ;;

        "Manage Courses")
            ManageCourses
            ;;

        "Manage Teaching Affairs")
            ManageTeachingAffairs
            ;;
        *)
            break
            ;;
        esac
    done
}

function DisplayTeacherMenu() {
    echo "DisplayTeacherMenu"
}

function DisplayStudentMenu() {
    echo "DisplayTeacherMenu"
}

function ManageTeacherAccounts() {
    while [ 1 ]; do
        selection=$(echo "SELECT * FROM teacher" | $mysql_default |
            tr '\t' '\n' | yad --list --title "Teacher Accounts" \
            --column "Teacher ID" --column "Password" \
            --column "Name" $list_size --button="Back:3" \
            --button="Add:1" --button="Delete:2" --button="Modify:0")

        case $? in
        0)
            if [[ -z $selection ]]; then
                Err "Wrong selection" "Must select an account"
                continue
            fi

            cur_id=$(echo "$selection" | cut -d '|' -f 1)
            cur_pass=$(echo "$selection" | cut -d '|' -f 2)
            cur_name=$(echo "$selection" | cut -d '|' -f 3)

            result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(teacher_id) FROM teacher WHERE teacher_id='$cur_id'")

            if [ $result -ne 1 ]; then
                Err "Fail to Modify Account" \
                    "Cannot find a teacher account whose ID is '$cur_id'"
                continue
            fi

            form=$(yad --form --title "Modify Teacher Account" \
                --text "Modify a teacher account" \
                --field="Teacher ID" "$cur_id" \
                --field="Password" "$cur_pass" \
                --field="Name" "$cur_name" $form_size)

            if [ -z $form ]; then
                continue
            fi

            new_id=$(echo "$form" | cut -d '|' -f 1)
            new_pass=$(echo "$form" | cut -d '|' -f 2)
            new_name=$(echo "$form" | cut -d '|' -f 3)

            if [ ${#new_id} -gt 10 ]; then
                Err "Fail to Modify Teacher Account" "Teacher ID is too long. Expected under or equal 10 characters."
                continue
            elif [ ${#new_pass} -gt 32 ]; then
                Err "Fail to Modify Teacher Account" "Password is too long. Expected under or equal 32 characters."
                continue
            elif [ ${#new_name} -gt 40 ]; then
                Err "Fail to Modify Teacher Account" "Name is too long. Expected under or equal 40 characters."
                continue
            fi

            if [[ -n $new_id ]] && [[ -n $new_pass ]] && [[ -n $new_name ]]; then
                mysql -u $mysql_username -p$mysql_password HW <<EOF
                UPDATE teacher SET teacher_id='$new_id', password='$new_pass', name='$new_name' WHERE teacher_id='$cur_id';
EOF

            else

                Err "Fail to Modify Teacher Account" "All the entries in the form should be non-empty."

            fi
            ;;
        1)
            form=$(zenity --forms --title "Create Teacher Account" \
                --text "Create a teacher account" \
                --add-entry "Teacher ID" \
                --add-password "Password" \
                --add-entry "Name")

            if [ $? -eq 0 ]; then
                new_id=$(echo "$form" | cut -d '|' -f 1)
                new_pass=$(echo "$form" | cut -d '|' -f 2)
                new_name=$(echo "$form" | cut -d '|' -f 3)

                if [ ${#new_id} -gt 10 ]; then
                    Err "Fail to Create Teacher Account" "Teacher ID is too long. Expected under or equal 10 characters."
                    continue
                elif [ ${#new_pass} -gt 32 ]; then
                    Err "Fail to Create Teacher Account" "Password is too long. Expected under or equal 32 characters."
                    continue
                elif [ ${#new_name} -gt 40 ]; then
                    Err "Fail to Create Teacher Account" "Name is too long. Expected under or equal 40 characters."
                    continue
                fi

                if [[ -n $new_id ]] && [[ -n $new_pass ]] && [[ -n $new_name ]]; then
                    result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(teacher_id) FROM teacher WHERE teacher_id='$new_id'")

                    if [ $result -eq 0 ]; then
                        mysql -u $mysql_username -p$mysql_password HW <<EOF
                        INSERT INTO teacher VALUES('$new_id', '$new_pass', '$new_name');
EOF
                    else
                        Err "Fail to Create Teacher Account" "There has already been an account whose ID=$new_id."
                    fi
                else
                    Err "Fail to Create Teacher Account" "All the entries in the form should be non-empty."
                fi
            fi
            ;;

        2)
            if [[ -z $selection ]]; then
                Err "Wrong selection" "Must select an account"
                continue
            fi

            delete_id=$(echo "$selection" | cut -d '|' -f 1)

            result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(teacher_id) FROM teacher WHERE teacher_id='$delete_id'")

            if [ $result -eq 1 ]; then
                mysql -u $mysql_username -p$mysql_password HW <<EOF
                DELETE FROM teacher WHERE teacher_id=$delete_id;
EOF
            else
                Err "Fail to Delete Account" \
                    "Cannot find a teacher account whose ID is '$delete_id'"
            fi
            ;;
        *)
            break
            ;;
        esac
    done
}

function ManageCourses() {
    while [ 1 ]; do
        selection=$(echo "SELECT * FROM course" | $mysql_default |
            tr '\t' '\n' | yad --list --title "Courses" \
            --column "Course ID" --column "Name" \
            $list_size --button="Back:3" --button="Add:1" \
            --button="Delete:2" --button="Modify:0")

        case $? in
        0)
            if [[ -z $selection ]]; then
                Err "Wrong selection" "Must select a course"
                continue
            fi

            cur_id=$(echo "$selection" | cut -d '|' -f 1)
            cur_name=$(echo "$selection" | cut -d '|' -f 2)

            result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(course_id) FROM course WHERE course_id='$cur_id'")

            if [ $result -ne 1 ]; then
                Err "Fail to Modify Course" \
                    "Cannot find a course whose ID is '$cur_id'"
                continue
            fi

            form=$(yad --form --title "Modify Course" \
                --text "Modify a course" \
                --field="Course ID" "$cur_id" \
                --field="Name" "$cur_name" $form_size)

            if [ -z $form ]; then
                continue
            fi

            new_id=$(echo "$form" | cut -d '|' -f 1)
            new_name=$(echo "$form" | cut -d '|' -f 2)

            if [ ${#new_id} -gt 10 ]; then
                Err "Fail to Modify Course" "Course ID is too long. Expected under or equal 10 characters."
                continue
            elif [ ${#new_name} -gt 40 ]; then
                Err "Fail to Modify Course" "Name is too long. Expected under or equal 40 characters."
                continue
            fi

            if [[ -n $new_id ]] && [[ -n $new_name ]]; then

                mysql -u $mysql_username -p$mysql_password HW <<EOF
                UPDATE course SET course_id='$new_id', name='$new_name' WHERE course_id='$cur_id';
EOF
            else

                Err "Fail to Modify Course" "All the entries in the form should be non-empty."

            fi
            ;;
        1)
            form=$(zenity --forms --title "Create Course" \
                --text "Create a course account" \
                --add-entry "Course ID" \
                --add-entry "Name")

            if [ $? -eq 0 ]; then
                new_id=$(echo "$form" | cut -d '|' -f 1)
                new_name=$(echo "$form" | cut -d '|' -f 2)

                if [ ${#new_id} -gt 10 ]; then
                    Err "Fail to Create Course" "Course ID is too long. Expected under or equal 10 characters."
                    continue
                elif [ ${#new_name} -gt 40 ]; then
                    Err "Fail to Create Course" "Name is too long. Expected under or equal 40 characters."
                    continue
                fi

                if [[ -n $new_id ]] && [[ -n $new_name ]]; then
                    result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(course_id) FROM course WHERE course_id='$new_id'")

                    if [ $result -eq 0 ]; then
                        mysql -u $mysql_username -p$mysql_password HW <<EOF
                        INSERT INTO course VALUES('$new_id', '$new_name');
EOF
                    else
                        Err "Fail to Create Course" "There has already been a course whose ID=$new_id."
                    fi
                else
                    Err "Fail to Create Course" "All the entries in the form should be non-empty."
                fi
            fi
            ;;

        2)
            if [[ -z $selection ]]; then
                Err "Wrong selection" "Must select a course"
                continue
            fi

            delete_id=$(echo "$selection" | cut -d '|' -f 1)

            result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(course_id) FROM course WHERE course_id='$delete_id'")

            if [ $result -eq 1 ]; then
                mysql -u $mysql_username -p$mysql_password HW <<EOF
                DELETE FROM course WHERE course_id=$delete_id;
EOF
            else
                Err "Fail to Delete Course" \
                    "Cannot find a course whose ID is '$delete_id'"
            fi
            ;;
        *)
            break
            ;;
        esac

    done
}

function ManageTeachingAffairs() {
    echo "ManageTeachingAffairs"
}

function ManageStudentAccounts() {
    echo "ManageStudentAccounts"
}

function ManageInformation() {
    echo "ManageInformation"
}

function ManageHomework() {
    echo "ManageHomework"
}

function ManageStatus() {
    echo "ManageStatus"
}

function Err() {
    zenity --error --title "$1" $error_size --text "$2"
}

# 主函数调用
main
