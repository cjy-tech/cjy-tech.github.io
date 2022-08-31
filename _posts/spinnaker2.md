x
1. 커밋 ID 얻어오기

먼저 첫 브랜치의 커밋과 개발 후 마지막 커밋을 얻어와야 했습니다. 그래서 Jenkins Execute shell에서 기본적으로 제공해주는 환경 변수들을 확인해보니,

`GIT_COMMIT = The commit hash being checked out.`

이 변수가 의미하는 건 개발 마지막 커밋이었고, 이와 git show --pretty=format%P를 이용해 해당 커밋의 부모 커밋 ID를 얻을 수 있었습니다.
(git show --pretty=format 옵션 정보 https://git-scm.com/docs/pretty-formats)
```bash
echo "GIT_COMMIT=${GIT_COMMIT}" # Merge Commit sha1(refs/remotes/origin/pr/PR_번호/merge)의 실제 Commit ID

GIT_SHOW=`git show --pretty='format:%P' ${GIT_COMMIT}` # Merge Commit의 Source Commit과 Target Commit을 출력

COMMIT_IDS=(${GIT_SHOW})
```
2. 가장 많이 변한 모듈 찾기

그러면 이제 가장 많이 변한 모듈만 찾으면 되고 그 모듈의 디렉토리 경로만 빼올 수 있으면 해결될 것 같았습니다. 그런데 여기서....

가장 많이 변한 모듈은 어떻게 판단할까...?

위의 고민이 생겼습니다. 결국 변한 모듈의 변한 코드량까지 추출을 해야하는 것일까 라는 생각을 잠시 했으나, 그냥 변한 파일 수로 간단히 구현하자!라고 마음을 먹었습니다.
그래서 merge 커밋과 diff를 떠서 모듈 디렉토리 명까지만 추출하고, 가장 많은 파일이 변화된 모듈을 추출하는 작업을 수행했습니다. 이건 spring에 한정된 코드라서 구현은 각 프로젝트마다 달라질 수 있을 것 같습니다.
```bash
# Merge Commit과 Target Commit을 diff 하여 파일 명만 추출 -> 모듈 명만 추출하기 위해 문자열 처리 (Spring 프로젝트라서 src 폴더, pom.xml 상위 폴더로 지정)
GIT_DIFF=`git diff --name-only ${GIT_COMMIT}..${COMMIT_IDS[0]} | sed 's/\/src.*$//' | sed 's/\/pom.*$//'` 

IFS=$'\n' MODULES="$GIT_DIFF"
# 모듈 명이 가장 많이 나온 순서 대로 정렬
UNIQUE_MODULES=($(printf "%s\n" "${MODULES[@]}"  | uniq -c | sort -nr | awk '{printf "%s\n", $2}'))
# 해당 모듈을 properties에 저장
echo MODULE=${UNIQUE_MODULES} > build.properties
```
3. 모듈 빌드

이제 해당 모듈을 빌드만 하면 끝이 납니다!
아까 모듈을 저장한 변수를 환경 변수로 등록하기 위해서 Inject environment variables 스텝을 추가합니다.
![image](https://user-images.githubusercontent.com/33619494/187606149-0b335415-f0f6-4da4-975b-d418a37b6553.png)
