#!/bin/bash
echo "--------------------------"
echo "User Name: Heo Min Kyung"
echo "Student Number: 12215543"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item'"
echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.item'"
echo "4. Delete the 'IMDb URL' from 'u.item'"
echo "5. Get the data about users from 'u.user'"
echo "6. Modify the format of 'release date' in 'u.item'"
echo "7. Get the data of movies rated by a specific 'user.id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "-----------------------"

stop="N"
until [ $stop = "Y" ]
do 
	echo -e
	read -p "Enter your choice [ 1-9 ] " choice
	case $choice in
	1)
		read -p "Please enter 'movie id'(1~1682): " id
		awk -F'|' -v num=$id 'num==$1{print $0}' u.item
	;;
	
	2)
		read -p "Do you want to get the data of action genre movies from 'u.item'?(y/n) " ans
		awk -F'|' -v num=$ans 'num=="y" && $7==1{print $1,$2}' u.item | head
	;;
	
	3)
		read -p "Please enter the 'movie id'(1~1682): " id
		awk -v num=$id 'num==$2{sum+=$3;count++} END{printf("average rating of %d : %.5f\n",num,sum/count)}' u.data
	;;

	4) 
		read -p "Do you want to delete the 'IMDb URL' from 'u.item'?" ans
		awk -v num=$ans 'num=="y"{print $0}' u.item | head | sed -E 's/(http)[^\)]*\)//g' 
	;;
	
	5) 	
		read -p "Do you want to get the data about users from 'u.user?'(y/n)" ans
		awk -F'|' -v num=$ans 'num=="y"{printf("\nuser %d is %d years old %s %s",$1,$2,$3,$4)}' u.user | head -11
	;;
	6) 
		read -p "Do you want to Modify the format of 'release data' in 'u.item?(y/n)" ans
		awk -F'|' -v num=$ans 'num=="y"{if($1>=1673 && $1<=1682) print $0}' u.item | sed -E 's/([0-9]+)-(.*)-([0-9]+)/\3\2\1/g' | sed -E -e 's/Jan/01/g' -e 's/Feb/02/g' -e 's/Mar/03/g' -e 's/Apr/04/g' -e 's/May/05/g' -e 's/Jun/06/g' -e 's/Jul/07/g' -e 's/Aug/08/g' -e 's/Sep/09/g' -e 's/Oct/10/g' -e 's/Nov/11/g' -e 's/Dec/12/g'
	;;
	
	7) 
		read -p "Please enter the 'user id' (1~943) " ans
		sort -k2,2 -sn u.data | awk -v userid=$ans '{if(userid==$1) {print $2} }' > movieid
		awk '{printf("%d|",$0)}' movieid
		echo -e
		awk -F'|' 'FNR==NR {movie_ids[$0]; next} $1 in movie_ids {printf ("\n%d|%s ",$1,$2)}' movieid u.item | head -11
	;;
	
	8) 
		read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer?(y/n) " ans
		awk -F'|' -v num=$ans 'num=="y"{if( ($2>=20 && $2<=29) && $4=="programmer") {print $1}}' u.user > userid
		awk 'FNR==NR {user_ids[$0]; next} $1 in user_ids {print $1,$2,$3}' userid u.data > avg.data
		sort -k2,2 -sn -o avg.data avg.data
		for i in $(seq 1 1682) 
			do 
				awk -v movid=$i 'movid==$2 {sum+=$3;count++} END{if(count>0) printf("%d %.5g\n",movid,sum/count)}' avg.data
			done
	;;

	9) 
		echo "Bye!"
		stop="Y"
	;;

	*) echo "Error: Invalid choice."

	;;
	esac
done
