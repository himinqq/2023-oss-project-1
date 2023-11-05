# 2023-oss-project-1

### 프로그램 흐름 제어 - until loop 사용 
stop을 변수로 두고, 9번을 선택하면 stop = Y로 할당하여 종료되도록 작성했습니다.

```bash 
stop="N"
until [ $stop = "Y" ]
do
        echo -e
        read -p "Enter your choice [ 1-9 ] " choice
        case $choice in
        
        9)
                echo "Bye!"
                stop="Y"
        ;;

        *) echo "Error: Invalid choice."
        ;;
        esac
done
```
### 1. Get the data of the movie identified by a specific 'movie id' from 'u.item'

```bash 
read -p "Please enter 'movie id'(1~1682): " id
awk -F'|' -v num=$id 'num==$1{print $0}' u.item
```
사용자 입력값을 awk에서 변수로 사용하기위해 -v 옵션을 사용했습니다.  
사용자 입력값인 id와 u.item파일의 1번째 필드의 값인 movie id가 같은 레코드를 출력하도록 패턴과 액션을 정의했습니다.

### 2. Get the data of action genre movies from 'u.item'

```bash 
read -p "Do you want to get the data of action genre movies from 'u.item'?(y/n) " ans
awk -F'|' -v num=$ans 'num=="y" && $7==1{print $1,$2}' u.item | head
```
사용자 입력이 y이고 u.item의 7번째 필드가 1으로 액션 장르의 영화일때 u.item의 movie id와 제목을 출력합니다.  
head 명령어로 10줄을 출력하도록 설정했습니다.

### 3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.item'

```bash 
read -p "Please enter the 'movie id'(1~1682): " id
awk -v num=$id 'num==$2{sum+=$3;count++} END{printf("average rating of %d : %.5f\n",num,sum/count)}' u.data
```
사용자 입력값인 id와 u.data파일의 2번째 필드의 값인 movie id가 동일하면 해당 영화의 평점을 sum에 더하고 count를 증가시켜 총 개수를 셉니다.  
u.data파일의 모든 레코드를 수행하고 END이후 해당 영화의 모든 평점을 누적한 sum을 count로 나누어 평균을 계산하고 출력합니다.

### 4. Delete the 'IMDb URL' from 'u.item'
```bash 
read -p "Do you want to delete the 'IMDb URL' from 'u.item'?" ans
awk -v num=$ans 'num=="y"{print $0}' u.item | head | sed -E 's/(http)[^\)]*\)//g'
```
사용자 입력값이 y 일때만 u.item의 모든 레코드의 데이터를 출력하여 파이프로 넘깁니다.  
sed -E 옵션으로 확장된 정규 표현식을 사용합니다.  
's/(http)[^\)]*\)//g' 는 "http"다음에 나오는 ')'문자를 포함하지 않는 모든 문자열을 찾아서 삭제합니다.

> (http)로 패턴을 그룹화하여 http로 시작하고, [^\)]* 닫는괄호가 아닌 문자가 0개이상 있으며, 닫는괄호로 끝나는 표현식 패턴을 
//로 대치하여 패턴에 일치하는 부분을 비워서 삭제하도록 작성했습니다.

### 5. Get the data about users from 'u.user'
```bash 
read -p "Do you want to get the data about users from 'u.user?'(y/n)" ans
awk -F'|' -v num=$ans 'num=="y"{printf("\nuser %d is %d years old %s %s",$1,$2,$3,$4)}' u.user | head -11
```
사용자 입력이 y이면 printf를 사용하여 사용자 정보를 출력합니다. 
u.data파일은 필드 순서대로 user id, age, gender, occupation의 데이터를 가집니다.

### 6. Modify the format of 'release date' in 'u.item'
```bash 
read -p "Do you want to Modify the format of 'release data' in 'u.item?(y/n)" ans
awk -F'|' -v num=$ans 'num=="y"{if($1>=1673 && $1<=1682) print $0}' u.item | sed -E 's/([0-9]+)-(.*)-([0-9]+)/\3\2\1/g' | sed -E -e 's/Jan/01/g' -e 's/Feb/02/g' -e 's/Mar/03/g' -e 's/Apr/04/g' -e 's/May/05/g' -e 's/Jun/06/g' -e 's/Jul/07/g' -e 's/Aug/08/g' -e 's/Sep/09/g' -e 's/Oct/10/g' -e 's/Nov/11/g' -e 's/Dec/12/g'
```
u.item파일의 3번째 필드인 release date의 형식을 수정합니다.  
movie id의 범위가 1673~1682인 10줄만 출력해야 하기 때문에 awk의 액션 내부에 if($1>=1673 && $1<=1682)로 범위를 제한하여 출력값을 파이프로 넘깁니다.  
's/([0-9]+)-(.*)-([0-9]+)/\3\2\1/g'는 date-month-year의 순서를 year month date으로 변경합니다.
> ([0-9]+) : [char1-char2]로 숫자범위를 지정하고 그룹화하여 0-9범위의 숫자가 1개이상 존재하는 패턴을 의미합니다.  <br/>
> (.*) : 모든 문자열을 의미합니다.

### 7. Get the data of movies rated by a specific 'user.id' from 'u.data'
```bash 
read -p "Please enter the 'user id' (1~943) " ans
sort -k2,2 -sn u.data | awk -v userid=$ans '{if(userid==$1) {print $2} }' > movieid
awk '{printf("%d|",$0)}' movieid
echo -e
awk -F'|' 'FNR==NR {movie_ids[$0]; next} $1 in movie_ids {printf ("\n%d|%s ",$1,$2)}' movieid u.item | head -11
```
sort -k2,2 -sn u.data  "u.data" | awk -v userid=$ans '{if(userid==$1) {print $2} }' > movieid
파일을 2번째 필드 기준으로 숫자 정렬하고 사용자 입력값인 user id 값에 해당하는 사용자가 평가한 movie id를 추출하여 movieid파일로 리다이렉션합니다.  
> -k 옵션 : 정렬 키를 지정  <br/>
> -n 옵션 : 숫자로 정렬하도록 지정  <br/>
> -s 옵션 : 같은 우선순위를 갖는 레코드의 순서가 뒤바뀌지 않고 stable하게 정렬한다.  <br/>

awk -F'|' 'FNR==NR {movie_ids[$0]; next} $1 in movie_ids {printf ("\n%d|%s ",$1,$2)}' movieid u.item | head -11
movieid파일에 있는 movie id 목록을 기반으로 u.item의 파일에서 영화 정보를 출력합니다. <br/>
> FNR=현재 파일의 레코드 번호, NR=모든 파일에서의 레코드 번호 <br/>
> FNR==NR {movie_ids[$0]; next} movieid파일 처리 - movie_ids배열에 파일의 모든 레코드를 저장 <br/>
> $1 in movie_ids {printf ("\n%d|%s ",$1,$2)} u.item파일 처리 - $1=현재 레코드의 1번째 필드. movie_ids배열에 있을 경우 1,2번째 필드 출력 <br/>

### 8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'
```bash 
read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer?(y/n) " ans
awk -F'|' -v num=$ans 'num=="y"{if( ($2>=20 && $2<=29) && $4=="programmer") {print $1}}' u.user > userid
awk 'FNR==NR {user_ids[$0]; next} $1 in user_ids {print $1,$2,$3}' userid u.data > avg.data
sort -k2,2 -sn -o avg.data avg.data
for i in $(seq 1 1682)
	do
		awk -v movid=$i 'movid==$2 {sum+=$3;count++} END{if(count>0) printf("%d %.5g\n",movid,sum/count)}' avg.data
	done
```
awk -F'|' -v num=$ans 'num=="y"{if( ($2>=20 && $2<=29) && $4=="programmer") {print $1}}' u.user > userid  
> 나이가 20대이고, 직업이 programmer인 사용자의 id를 추출하여 userid파일로 리다이렉션 합니다. <br/>

awk 'FNR==NR {user_ids[$0]; next} $1 in user_ids {print $1,$2,$3}' userid u.data > avg.data  
> userid를 user_ids배열에 저장하고, 해당 사용자가 평가한 movie id와 평점을 user id와 함께 추출하여 avg.data파일로 리다이렉션 합니다. <br/>

sort -k2,2 -sn -o avg.data avg.data  
> movie id 순서대로 출력하기 위해 avg.data를 정렬하고, 정렬된 데이터를 원본파일에 덮어씌웁니다. <br/>

for i in $(seq 1 1682) 반복문을 사용하여 모든 영화에 대해 평균을 구하도록 반복합니다.  
awk -v movid=$i 'movid==$2 {sum+=$3;count++} END{if(count>0) printf("%d %.5g\n",movid,sum/count)}' avg.data  
> 1-1682번의 movie id의 평균을 순차적으로 구합니다.   
이때 사용자가 평가하지 않은 영화에 대해서는 평균값을 계산할 수 없으므로 if(count>0)조건을 추가했습니다.
