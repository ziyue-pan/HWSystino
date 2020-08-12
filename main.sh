#! /bin/bash

# 临时变量声明
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

        selection=$(zenity --list --title "Choose Your Identity" \
            --cancel-label Quit \
            --column "Identity" \
            "Administrator" \
            "Teacher" \
            "Student")

        if [ $? -eq 1 ]; then
            break
        fi

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
    entry=$(zenity --title "Login As Administrator" --password --username)

    if [ $? -eq 0 ]; then
        admin_username=$(echo $entry | cut -d'|' -f1)
        admin_password=$(echo $entry | cut -d'|' -f2)

        result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(admin_id) FROM admin WHERE admin_id='$admin_username' AND password='$admin_password'")

        if [ $result -eq 1 ]; then
            echo "successfully login in as administrator"
            DisplayAdminMenu
        else
            Err "Fail to Login in as Administrator" \
                "Wrong matches! Please re-check your username or password"
        fi
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
            tr '\t' '\n' | zenity --list --title "Teacher Accounts" \
            --text "" --column "Teacher ID" --column "Password" \
            --column "Name" $list_size --extra-button "Add" \
            --extra-button "Delete" --ok-label "Modify")

        if [ $? -eq 1 ]; then
            if [[ $selection = "Delete" ]]; then
                echo "delete account"
            elif [[ $selection = "Add" ]]; then
                echo "add account"
            else
                break
            fi
        else
            if [[ -z $selection ]]; then
                Err "Wrong selection" "Must select an account"
            else
                echo $selection
            fi

        fi
    done
}

function ManageCourses() {
    echo "ManageCourses"
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
