#! /bin/bash

# 临时变量声明
zenity_size=" --height 160 --width 320 "
temp1=$(mktemp -t temp1.XXXXXX)

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
            break
        else
            zenity --error --title "Wrong Username or Password" $zenity_size \
                --text "Cannot connect to your MySQL system. Please try again."
        fi
    done

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
    init_file="$PWD/init.sql"
    if [ -e $init_file ]; then
        mysql -u $mysql_username -p$mysql_password <$init_file

        if [ $? -eq 0 ]; then
            echo "initialization done!"
        else
            zenity --error --title "Fail to Initialize Database" \
                $zenity_size --text "Please check your init.sql script."
            exit 1
        fi

    else
        zenity --error --title "Fail to Initialize Database" \
            $zenity_size --text "Cannot find file: $init_file"
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
        else
            zenity --error --title "Fail to Login in as Administrator" \
                $zenity_size --text "Wrong matches! Please re-check your username or password"
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
            zenity --error --title "Fail to Login in as Teacher" \
                $zenity_size --text "Wrong matches! Please re-check your username or password"
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
            zenity --error --title "Fail to Login in as Student" \
                $zenity_size --text "Wrong matches! Please re-check your username or password"
        fi
    fi
}

# 主函数调用
main
