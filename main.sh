#! /bin/bash

# 临时变量声明
temp1=$(mktemp -t temp1.XXXXXX)

# 前向函数声明
function main() {

    login_flag=0

    while [ $login_flag == 0 ]; do
        mysql_entry=$(zenity --title "Login In Your MySQL" --password --username)

        if [ $? -eq 0]; then
            mysql_username=$(echo $mysql_entry | cut -d'|' -f1)
            mysql_password=$(echo $mysql_entry | cut -d'|' -f2)
        else
            exit 0
        fi

        if [ ! $(mysql -u $mysql_username -p$mysql_password -e ";") ]; then
            login_flag=1
        else
            zenity --error --title "Wrong Username or Password" \
            --text "Cannot connect to your MySQL system. Please try again."
        fi
    done

    mysql_entry=$(zenity --title "Login In Your MySQL" --password --username)

    # if [ $? -eq 0 ]; then
    #     mysql_username=$(echo $mysql_entry | cut -d'|' -f1)
    #     mysql_password=$(echo $mysql_entry | cut -d'|' -f2)

    #     mysql -u$mysql_username -p$mysql_password -e

    #     if [ $? -eq 0 ]; then
    #         echo "success".
    #         exit 0
    #     else
    #         echo "fail".
    #         exit 0
    #     fi

    #     # mysql_db=$(mysql -u$mysql_username -p$mysql_password HW)
    #     # mysql_op=$(mysql -N HW -u$mysql_username -p$mysql_password)
    #     # result=$(mysql -s -N)
    # else
    #     exit 0
    # fi

    Initial
    while [ 1 ]; do

        zenity --list --title "Choose Your Identity" \
            --column "Identity" \
            "Administrator" \
            "Teacher" \
            "Student" >$temp1

        if [ $? -eq 1 ]; then
            break
        fi

        selection=$(cat $temp1)

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
    echo "Initial Done"

}

function LoginAdmin() {
    entry=$(zenity --title "Login As Administrator" --password --username)

    if [ $? -eq 0 ]; then
        admin_username=$(echo $entry | cut -d'|' -f1)
        admin_password=$(echo $entry | cut -d'|' -f2)
        echo $admin_username
        echo $admin_password
        result=$(mysql -s -N)
    fi
}

function LoginTeacher() {
    entry=$(zenity --title "Login As Teacher" --password --username)

    if [ $? -eq 0 ]; then
        teacher_username=$(echo $entry | cut -d'|' -f1)
        teacher_password=$(echo $entry | cut -d'|' -f2)
        echo $teacher_username
        echo $teacher_password
    fi
}

function LoginStudent() {
    entry=$(zenity --title "Login As Student" --password --username)

    if [ $? -eq 0 ]; then
        student_username=$(echo $entry | cut -d'|' -f1)
        student_password=$(echo $entry | cut -d'|' -f2)
        echo $student_username
        echo $student_password
    fi
}

# 主函数调用
main
