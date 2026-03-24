-- ------------------------------------------
-- Chapter 2. 실전 SQL- 워밍업 (1)
-- ------------------------------------------

-- 1) “소설” 카테고리의 모든 책을 조회하자.
select
	b.id, b.name
from book b
join book_category bc on b.book_category_id=bc.id # join 과 from 은 '어떤 테이블' 사용할지
where bc.name='소설' # where은 결정된 테이블에서 '행' 컬러내는 것

-- 2) 회원별 대여 횟수 상위 5명을 조회하자. 
select
 m.id, count(*) as rent_count
from member m
join rent r on m.id=r.member_id
group by m.id
order by rent_count desc # desc 빼먹음
limit 5;

-- 3) 각 회원이 좋아요를 누른 책의 카테고리별 분포를 조회하자.
select
	m.name, bc.name as category, count(*) as like_count
from member m
# 여러번 join 할 때는, and 가 아니라 그냥 join on 여러 번 써야함
join book_likes l 
	on m.id=l.member_id
join book b 
	on l.book_id=b.id
join book_category bc 
	on b.book_category_id=bc.id
group by m.id, m.name, b.book_category_id, bc.name
order by m.name asc, member_category_like desc

-- 4) 각 회원이 좋아요를 누른 책의 카테고리별 분포를 조회하자. 
with like_count as (
	SELECT COUNT(*)
	FROM book_likes bl 
	JOIN book b ON bl.book_id=b.id 
	WHERE bl.member_id = m.id AND b.book_category_id=bc.id
)
SELECT m.name, bc.name as category, 
	( SELECT *
		FROM like_count
	) as like_count 

FROM member m
CROSS JOIN book_category bc
WHERE (SELECT *
		FROM like_count) > 0;


-- ------------------------------------------
-- Chapter 2. 실전 SQL- SQL과 페이지네이션 (1)
-- ------------------------------------------
-- 워크북에서 제공되는 sql 코드 CTE로 수정
select * from book as b
	 join (select count(*) as like_count 
						from book_likes
							group by book_id) as likes on b.id = likes.book_id
			where likes.like_count < (select count(*) from book_likes where book_id = 3)
				order by likes.like_count desc, b.id desc limit 15;

-- 위와 같은 코드 (서브쿼리 -> CTE로 수정)
WITH like_count AS (
    SELECT book_id, COUNT(*) AS c
    FROM book_likes
    GROUP BY book_id
)
SELECT *
FROM book AS b
JOIN like_count AS lc
    ON b.id = lc.book_id
WHERE lc.c < (
    SELECT c
    FROM like_count
    WHERE book_id = 3
)
ORDER BY lc.c DESC, b.id DESC
LIMIT 15;