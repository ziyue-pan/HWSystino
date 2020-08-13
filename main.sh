#! /bin/bash

form_size="--height 200 --width 400 "
error_size=" --height 160 --width 320 "
list_size=" --height 640 --width 480 "
menu_size=" --height 280 --width 320"
info_size=" --height 640 --width 640 "

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

        if [[ -z $form ]]; then
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

function Err() {
    zenity --error --title "$1" $error_size --text "$2"
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

    result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(*) FROM teacher WHERE teacher_id='$username' AND password='$password'")

    if [ $result -eq 1 ]; then
        echo "successfully login in as teacher."
        saved_id=$username
        DisplayTeacherMenu
    else
        Err "Fail to Login in as Teacher" \
            "Wrong matches! Please re-check your username or password"
    fi
}

function LoginStudent() {
    result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(*) FROM student WHERE student_id='$username' AND password='$password'")

    if [ $result -eq 1 ]; then
        echo "successfully login in as student."
        saved_id=$username
        DisplayStudentMenu
    else
        Err "Fail to Login in as Student" \
            "Wrong matches! Please re-check your username or password"
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
    while [ 1 ]; do

        selection=$(zenity --list $menu_size \
            --title "Choose Your Operation" \
            --column "Operation" \
            "Display & Manage Courses" \
            "Manage Student Accounts" \
            "Manage Course Information" \
            "Manage Homework" \
            "Display Homework Completion Status" \
            "* Back")

        if [ $? -eq 1 ]; then
            break
        fi

        case $selection in
        "Display & Manage Courses")
            DisplayManageCourses
            ;;

        "Manage Student Accounts")
            ManageStudentAccounts
            ;;

        "Manage Course Information")
            ManageCourseInformation
            ;;

        "Manage Homework")
            ManageHomework
            ;;

        "Display Homework Completion Status")
            DisplayHomeworkCompletionStatus
            ;;

        *)
            break
            ;;
        esac
    done
}

function DisplayStudentMenu() {
    while [ 1 ]; do

        selection=$(zenity --list $menu_size \
            --title "Choose Your Operation" \
            --column "Operation" \
            "Display Your Courses" \
            "Display Course Information" \
            "Display Your Homework" \
            "* Back")

        if [ $? -eq 1 ]; then
            break
        fi

        case $selection in
        "Display Your Courses")
            DisplayStudentCourses
            ;;

        "Display Course Information")
            DisplayCourseInformation
            ;;

        "Display Your Homework")
            DisplayStudentHomework
            ;;
        *)
            break
            ;;
        esac
    done
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
                --field="Teacher ID:RO" "$cur_id" \
                --field="Password" "$cur_pass" \
                --field="Name" "$cur_name" $form_size)

            if [[ -z $form ]]; then
                continue
            fi

            new_pass=$(echo "$form" | cut -d '|' -f 2)
            new_name=$(echo "$form" | cut -d '|' -f 3)

            if [ ${#new_pass} -gt 32 ]; then
                Err "Fail to Modify Teacher Account" "Password is too long. Expected under or equal 32 characters."
                continue
            elif [ ${#new_name} -gt 40 ]; then
                Err "Fail to Modify Teacher Account" "Name is too long. Expected under or equal 40 characters."
                continue
            fi

            if [[ -n $new_pass ]] && [[ -n $new_name ]]; then
                mysql -u $mysql_username -p$mysql_password HW <<EOF
                UPDATE teacher SET password='$new_pass', name='$new_name' WHERE teacher_id='$cur_id';
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

            mysql -u $mysql_username -p$mysql_password HW <<EOF
            DELETE FROM teacher WHERE teacher_id='$delete_id';
            DELETE FROM binding WHERE teacher_id='$delete_id';
EOF
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
                --field="Course ID:RO" "$cur_id" \
                --field="Name" "$cur_name" $form_size)

            if [[ -z $form ]]; then
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

            mysql -u $mysql_username -p$mysql_password HW <<EOF
            DELETE FROM course WHERE course_id='$delete_id';
            DELETE FROM binding WHERE course_id='$delete_id';
            DELETE FROM election WHERE course_id='$delete_id';
            DELETE FROM homework WHERE course_id='$delete_id';
            DELETE FROM homework_handin WHERE course_id='$delete_id';
            DELETE FROM information WHERE course_id='$delete_id';
EOF
            ;;
        *)
            break
            ;;
        esac
    done
}

function ManageTeachingAffairs() {
    while [ 1 ]; do

        selection=$(echo "SELECT binding.course_id, course.name, binding.teacher_id, teacher.name FROM (binding INNER JOIN course ON binding.course_id=course.course_id) INNER JOIN teacher ON binding.teacher_id=teacher.teacher_id;" | $mysql_default | tr '\t' '\n' | yad --list --title "Course Bindings" \
            --column "Course ID" --column "Course Name" \
            --column "Teacher ID" --column "Teacher Name" \
            $list_size --button="Back:3" --button="Delete:2" --button="Add:1")

        case $? in
        0)
            c_id=$(echo "$selection" | cut -d '|' -f 1)
            c_name=$(echo "$selection" | cut -d '|' -f 2)
            t_id=$(echo "$selection" | cut -d '|' -f 3)
            t_name=$(echo "$selection" | cut -d '|' -f 4)

            yad --form --title "Binding Info" \
                --field="Course ID:RO" "$c_id" \
                --field="Course Name:RO" "$c_name" \
                --field="Teacher ID:RO" "$t_id" \
                --field="Teacher Name:RO" "$t_name"
            ;;
        1)
            form=$(zenity --forms --title "Create Binding" \
                --text "Create a course binding" \
                --add-entry "Course ID" \
                --add-entry "Teacher ID")

            if [ $? -eq 0 ]; then
                c_id=$(echo "$form" | cut -d '|' -f 1)
                t_id=$(echo "$form" | cut -d '|' -f 2)

                if [ ${#c_id} -gt 10 ]; then
                    Err "Fail to Create Binding" "Course ID is too long. Expected under or equal 10 characters."
                    continue
                elif [ ${#t_id} -gt 10 ]; then
                    Err "Fail to Create Course" "Teacher ID is too long. Expected under or equal 10 characters."
                    continue
                fi

                if [[ -n $t_id ]] && [[ -n $c_id ]]; then

                    result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(*) FROM course WHERE course_id='$c_id'")
                    if [ $result -ne 1 ]; then
                        Err "Fail to Create Binding" "No such course whose ID=$c_id."
                        continue
                    fi

                    result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(*) FROM teacher WHERE course_id='$t_id'")
                    if [ $result -ne 1 ]; then
                        Err "Fail to Create Binding" "No such teacher account whose ID=$t_id."
                        continue
                    fi

                    result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(*) FROM binding WHERE course_id='$c_id' AND teacher_id='$t_id'")

                    if [ $result -eq 0 ]; then
                        mysql -u $mysql_username -p$mysql_password HW <<EOF
                        INSERT INTO binding VALUES('$c_id', '$t_id');
EOF
                    else
                        Err "Fail to Create Binding" "There has already been such a binding."
                    fi
                else
                    Err "Fail to Create Binding" "All the entries in the form should be non-empty."
                fi
            fi
            ;;

        2)
            if [[ -z $selection ]]; then
                Err "Wrong selection" "Must select a binding"
                continue
            fi
            c_id=$(echo "$selection" | cut -d '|' -f 1)
            t_id=$(echo "$selection" | cut -d '|' -f 3)

            mysql -u $mysql_username -p$mysql_password HW <<EOF
            DELETE FROM binding WHERE course_id='$c_id' AND teacher_id='$t_id';
EOF
            ;;
        *)
            break
            ;;
        esac
    done
}

function ManageStudentAccounts() {
    while [ 1 ]; do
        selection=$(echo "SELECT * FROM student" | $mysql_default |
            tr '\t' '\n' | yad --list --title "Student Accounts" \
            --column "Student ID" --column "Password" \
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

            result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(*) FROM student WHERE student_id='$cur_id'")

            if [ $result -ne 1 ]; then
                Err "Fail to Modify Account" \
                    "Cannot find a student account whose ID is '$cur_id'"
                continue
            fi

            form=$(yad --form --title "Modify Student Account" \
                --text "Modify a student account" \
                --field="Student ID:RO" "$cur_id" \
                --field="Password" "$cur_pass" \
                --field="Name" "$cur_name" $form_size)

            if [[ -z $form ]]; then
                continue
            fi

            new_pass=$(echo "$form" | cut -d '|' -f 2)
            new_name=$(echo "$form" | cut -d '|' -f 3)

            if [ ${#new_pass} -gt 32 ]; then
                Err "Fail to Modify Student Account" "Password is too long. Expected under or equal 32 characters."
                continue
            elif [ ${#new_name} -gt 40 ]; then
                Err "Fail to Modify Student Account" "Name is too long. Expected under or equal 40 characters."
                continue
            fi

            if [[ -n $new_pass ]] && [[ -n $new_name ]]; then
                mysql -u $mysql_username -p$mysql_password HW <<EOF
                UPDATE student SET password='$new_pass', name='$new_name' WHERE student_id='$cur_id';
EOF

            else
                Err "Fail to Modify Student Account" "All the entries in the form should be non-empty."
            fi
            ;;
        1)
            form=$(zenity --forms --title "Create Student Account" \
                --text "Create a student account" \
                --add-entry "Student ID" \
                --add-password "Password" \
                --add-entry "Name")

            if [ $? -eq 0 ]; then
                new_id=$(echo "$form" | cut -d '|' -f 1)
                new_pass=$(echo "$form" | cut -d '|' -f 2)
                new_name=$(echo "$form" | cut -d '|' -f 3)

                if [ ${#new_id} -gt 10 ]; then
                    Err "Fail to Create Student Account" "Student ID is too long. Expected under or equal 10 characters."
                    continue
                elif [ ${#new_pass} -gt 32 ]; then
                    Err "Fail to Create Student Account" "Password is too long. Expected under or equal 32 characters."
                    continue
                elif [ ${#new_name} -gt 40 ]; then
                    Err "Fail to Create Student Account" "Name is too long. Expected under or equal 40 characters."
                    continue
                fi

                if [[ -n $new_id ]] && [[ -n $new_pass ]] && [[ -n $new_name ]]; then
                    result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(*) FROM student WHERE student_id='$new_id'")

                    if [ $result -eq 0 ]; then
                        mysql -u $mysql_username -p$mysql_password HW <<EOF
                        INSERT INTO student VALUES('$new_id', '$new_pass', '$new_name');
EOF
                    else
                        Err "Fail to Create Student Account" "There has already been an account whose ID=$new_id."
                    fi
                else
                    Err "Fail to Create Student Account" "All the entries in the form should be non-empty."
                fi
            fi
            ;;

        2)
            if [[ -z $selection ]]; then
                Err "Wrong selection" "Must select an account"
                continue
            fi

            delete_id=$(echo "$selection" | cut -d '|' -f 1)

            mysql -u $mysql_username -p$mysql_password HW <<EOF
            DELETE FROM student WHERE student_id='$delete_id';
            DELETE FROM binding WHERE student_id='$delete_id';
            DELETE FROM election WHERE student_id='$delete_id';
            DELETE FROM homework_handin WHERE student_id='$delete_id';
EOF
            ;;
        *)
            break
            ;;
        esac
    done
}

function DisplayManageCourses() {
    while [ 1 ]; do
        selection=$(echo "SELECT course_id, name FROM course NATURAL JOIN binding WHERE teacher_id='$saved_id'" |
            $mysql_default | tr '\t' '\n' | yad --list --title "Courses" --column "Course ID" --column "Name" \
            $list_size --button="Back:1" --button="Manage Elections:0")
        if [ $? -eq 0 ]; then
            if [[ -z $selection ]]; then
                Err "Wrong selection" "Must select a course."
                continue
            fi
            course_id=$(echo "$selection" | cut -d '|' -f 1)
            ManageElection
        else
            break
        fi
    done
}

function ManageElection() {
    while [ 1 ]; do
        selection=$(echo "SELECT student_id, name FROM student NATURAL JOIN election WHERE course_id='$course_id'" |
            $mysql_default | tr '\t' '\n' | yad --list --title "Elections" --column "Student ID" --column "Name" \
            $list_size --button="Back:3" --button="Delete:2" --button="Add:1")
        case $? in
        0)
            continue
            ;;
        1)
            stu_id=$(zenity --forms --title "Add a Student" \
                --text "Add a student in this course" \
                --add-entry "Student ID")
            if [ $? -ne 0 ]; then
                continue
            fi

            result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(*) FROM student WHERE student_id='$stu_id'")
            if [ $result -ne 1 ]; then
                Err "Fail to Add Student" "There is no student whose ID=$stu_id."
                continue
            fi

            result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(*) FROM election WHERE student_id='$stu_id' AND course_id='$course_id'")
            if [ $result -ne 0 ]; then
                Err "Fail to Add Student" "This student has already taken this course."
                continue
            fi

            mysql -u $mysql_username -p$mysql_password HW <<EOF
            INSERT INTO election VALUES('$course_id', '$stu_id');
            INSERT INTO homework_handin (course_id, student_id, create_time, complete, content)
                SELECT '$course_id', '$stu_id', C.create_time, FALSE, NULL
                    FROM  (SELECT create_time FROM homework WHERE course_id='$course_id') AS C;
EOF

            ;;
        2)
            if [[ -z $selection ]]; then
                Err "Wrong selection" "Must select a student"
                continue
            fi

            stu_id=$(echo "$selection" | cut -d '|' -f 1)
            mysql -u $mysql_username -p$mysql_password HW <<EOF
            DELETE FROM election WHERE course_id='$course_id' AND student_id='$stu_id';
            DELETE FROM homework_handin WHERE course_id='$course_id' AND student_id='$stu_id';
EOF
            ;;
        *)
            break
            ;;
        esac
    done
}

function ManageCourseInformation() {
    while [ 1 ]; do
        selection=$(echo "SELECT course_id, name, create_time, title FROM (information NATURAL JOIN course) WHERE course_id IN (SELECT course_id FROM binding WHERE teacher_id=$saved_id);" | $mysql_default | tr '\t' '\n' | yad --list --title "Course Information" --column "Course ID" --column "Course Name" --column "Create Time" --column "Title" $info_size --button="Back:3" --button="Delete:2" --button="Add:1" --button="Modify:0")

        case $? in
        0)

            if [[ -z $selection ]]; then
                Err "Wrong selection" "Must select a piece of information"
                continue
            fi

            course_id=$(echo "$selection" | cut -d '|' -f 1)
            name=$(echo "$selection" | cut -d '|' -f 2)
            create_time=$(echo "$selection" | cut -d '|' -f 3)
            title=$(echo "$selection" | cut -d '|' -f 4)
            content=$(echo "SELECT description FROM information WHERE course_id='$course_id' AND create_time='$create_time'" | $mysql_default)

            form=$(yad --form --title "Display & Modify Course Information" \
                --text "Modify a piece of course information" \
                --field="Course ID:RO" "$course_id" \
                --field="Course Name:RO" "$name" \
                --field="Create Time:RO" "$create_time" \
                --field="Title" "$title" \
                --field="Content:TXT" "$content" $form_size)

            if [ $? -eq 0 ]; then
                new_title=$(echo "$form" | cut -d '|' -f 4)
                new_content=$(echo "$form" | cut -d '|' -f 5)

                mysql -u $mysql_username -p$mysql_password HW <<EOF
                UPDATE information SET title='$new_title', description='$new_content' WHERE course_id='$course_id' AND create_time='$create_time';
EOF
            fi
            ;;
        1)
            form=$(yad --form --title "Add Course Information" \
                --text "Add a piece of course information" \
                --field="Course ID" \
                --field="Title" \
                --field="Content:TXT" $form_size)

            if [ $? -ne 0 ]; then
                continue
            fi

            c_id=$(echo "$form" | cut -d '|' -f 1)
            title=$(echo "$form" | cut -d '|' -f 2)
            content=$(echo "$form" | cut -d '|' -f 3)

            result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(*) FROM course WHERE course_id='$c_id'")
            if [ $result -eq 0 ]; then
                Err "Fail to Add Information" "No such course whose ID=$c_id."
                continue
            fi

            result=$(mysql -s -N HW $mysql_info <<<"SELECT COUNT(*) FROM binding WHERE course_id='$c_id' AND teacher_id='$saved_id'")
            if [ $result -eq 0 ]; then
                Err "Fail to Add Information" "You have no privilege to add information to this course."
                continue
            fi

            if [ ${#title} -gt 40 ]; then
                Err "Fail to Add Information" "Title is too long. Expected under or equal 40 characters."
                continue
            fi

            mysql -u $mysql_username -p$mysql_password HW <<EOF
            INSERT INTO information VALUES('$c_id', NOW(), '$title', '$content');
EOF
            ;;

        *)
            break
            ;;
        esac
    done
}

# TODO
function ManageHomework() {
    echo "ManageHomework"
}

function DisplayHomeworkCompletionStatus() {
    echo "ManageStatus"
}

function DisplayStudentCourses() {
    echo "DisplayStudentCourses"
}

function DisplayCourseInformation() {
    echo "DisplayCourseInformation"
}

function DisplayStudentHomework() {
    echo "DisplayStudentHomework"
}

# 主函数调用
main
