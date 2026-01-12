<div align="center">
<img width="1920" height="960" alt="recifit" src="https://github.com/user-attachments/assets/37474e41-112f-4563-9f6f-189171725326" />

</div>

## 📅 기간
- 2025.07 ~ (MVP 개발 완료 및 개선 중)
<a name="tableContents"></a>

<br/>

## 📑 목차

1. <a href="#project"> 프로젝트 소개</a>
1. <a href="#mainContents"> 주요 기능</a>
1. <a href="#skills"> 기술 스택</a>
1. <a href="#erd"> ERD</a>
1. <a href="#contents"> 화면 소개</a>

<br/>

## 📌 프로젝트 소개
<a name="project"></a>
Recifit은 냉장고에 보관 중인 재료를 정리하고,  
남은 재료로 만들 수 있는 레시피를 추천해주는 서비스입니다.

재료를 사두고도 무엇을 만들지 몰라 그대로 버리게 되는 경험에서 출발해,  
재료명·보관 위치·유통기한을 기록할 수 있도록 구성했습니다.

또한 남은 재료를 활용할 수 있도록 AI 기반 레시피 추천 기능을 제공하며,  
커뮤니티를 통해 레시피와 꿀팁들을 함께 나눌 수 있습니다.

아직 완벽한 서비스는 아니지만,  
직접 사용하며 불편한 점을 발견하고 하나씩 개선해 나가고 있습니다.

## 🚀 주요 기능
<a name="mainContents"></a>
### 🧊 재료 관리
- 재료명, 보관 위치, 유통기한 등록
- 보관 중인 재료 목록 한눈에 확인
- 사용 완료 또는 불필요한 재료 삭제

### 🤖 AI 레시피 추천
- 현재 보유한 재료 기반 레시피 추천
- 사용자 유형을 고려한 추천 결과 제공
- 유통기한이 임박한 재료 우선 활용

### 💬 커뮤니티
- 레시피 및 보관 팁 게시글 작성
- 게시글에 댓글을 통한 의견 공유
- 본인이 작성한 글/댓글 수정·삭제 가능

### 🔐 회원 관리
- JWT 기반 인증 (Access / Refresh Token)
- 카카오 OAuth2 로그인 지원



## 🛠️ 기술 스택
<a name="skills"></a>
### Backend
![Java](https://img.shields.io/badge/Java-17-007396?style=flat-square&logo=java)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.3.1-6DB33F?style=flat-square&logo=springboot)
![Spring Security](https://img.shields.io/badge/Spring%20Security-6.x-6DB33F?style=flat-square&logo=springsecurity)
![Spring Data JPA](https://img.shields.io/badge/Spring%20Data%20JPA-Hibernate-59666C?style=flat-square)
![JWT](https://img.shields.io/badge/JWT-Authentication-000000?style=flat-square)

### AI
![Spring AI](https://img.shields.io/badge/Spring%20AI-OpenAI-6DB33F?style=flat-square)
![OpenAI](https://img.shields.io/badge/OpenAI-GPT-412991?style=flat-square&logo=openai)

### Database
![MySQL](https://img.shields.io/badge/MySQL-8.x-4479A1?style=flat-square&logo=mysql)

### Infra & Deployment
![AWS EC2](https://img.shields.io/badge/AWS-EC2-FF9900?style=flat-square&logo=amazonaws)
![Nginx](https://img.shields.io/badge/Nginx-Reverse%20Proxy-009639?style=flat-square&logo=nginx)

### Frontend(UI)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter)

### Tools
![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat-square&logo=github)
![Swagger UI](https://img.shields.io/badge/Swagger-85EA2D?style=flat-square&logo=swagger)
![Postman](https://img.shields.io/badge/Postman-FF6C37?style=flat-square&logo=postman)


## 🗂️ ERD
<a name="erd"></a>
(업로드 예정)

## 🖼️ 화면 소개
<a name="contents"></a>

**1. 메인화면 & 회원가입 & 로그인**  
계정을 생성하고 로그인하여 나만의 냉장고와 레시피 서비스를 시작합니다.

<img width="4097" height="1934" alt="메인화면, 회원가입, 로그인_250905" src="https://github.com/user-attachments/assets/a9ebb8a7-2c00-4ab2-afeb-f7340ffc015a" />


---------

**2. 재료 추가**  
- 재료명, 보관 위치, 유통기한을 입력하거나 공공데이터 API를 통해 검색 후 등록합니다.  
- 등록된 재료는 메인 화면과 AI 추천에 반영됩니다.

<img width="3955" height="1934" alt="재료 추가_250822" src="https://github.com/user-attachments/assets/bdaf052b-153f-4dcd-9537-4f542f841bb7" />


---------

**3. 재료 현황/삭제**  
현재 등록된 재료 목록을 확인하고, 불필요하거나 이미 사용한 재료를 삭제합니다.

<img width="4170" height="2035" alt="재료현황 및 삭제_250822" src="https://github.com/user-attachments/assets/1d79f01b-8f6e-4e14-a2a3-a9b8ae29d2cb" />

---------

**4. AI 레시피 추천**  
- 생활 유형과 요리 실력에 맞춘 맞춤형 레시피를 제공합니다.  
- 유통기한이 임박한 재료를 우선적으로 활용하여 식재료 낭비를 줄입니다.

<img width="948" height="452" alt="레시피 추천_250823" src="https://github.com/user-attachments/assets/4daf9411-c36d-41c6-893f-65fabb60e71e" />

---------

**5. 커뮤니티**
- 레시피/팁 카테고리로 글을 작성하고, 최신순으로 목록을 확인할 수 있습니다.
- 작성/수정/삭제는 로그인 사용자만 가능합니다.

![커뮤니티_250823](https://github.com/user-attachments/assets/a69c55d2-bb6c-4df7-8c92-ecde80ddea84)

---------

**6. 커뮤니티 댓글**
- 게시글에 댓글을 작성하고, 최신순으로 목록을 확인 할 수 있습니다.
- 댓글 작성은 로그인 사용자만 가능하며, 댓글의 수정/삭제는 본인 댓글에 한해 허용됩니다.

![커뮤니티 댓글_250911](https://github.com/user-attachments/assets/bfeea179-22f6-4a70-9ba9-b5a0d87e53c8)




