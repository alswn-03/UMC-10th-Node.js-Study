-- ----------------------
-- Week2) 1주차 때 설계한 데이터베이스를 토대로 쿼리를 작성
-- ----------------------------


-- 1. 내가 진행중, 진행 완료한 미션 모아서 보는 쿼리(페이징 포함)
select
    m.id, m.reward, m.mission_spec,
    mm.status, store.name
from mission m
join member_mission mm
    on m.id=mm.mission_id
join store s
    on m.store_id=s.id
where mm.status= :status -- "진행 중 | 진행 완료"
    and mm.member_id= :memberId -- memberId
order by mm.updated_at desc, mm.id desc
limit 15 offset :offset;

-- 2. 리뷰 작성하는 쿼리, (* 사진의 경우는 일단 배제)

-- 리뷰 목록
select
    r.id, r.score, r.body
    m.name, ri.updated_at
from review r
join review_image ri on r.id=ri.review_id
join member m on r.member_id=m.id
where r.store_id= :storeId -- storeId
order by ri.updated_at desc;

-- 리뷰 작성
INSERT INTO review (member_id, store_id, body, score)
VALUES (:memberId, :storeId, :body, :score);


-- 3. 홈 화면 쿼리  (현재 선택 된 지역에서 도전이 가능한 미션 목록, 페이징 포함) 🥹
-- 도전이 가능한 미션 : member_mission 테이블에 추가되지 않은 mission
SELECT
    m.id AS mission_id,
    m.deadline,
    m.reward,
    m.mission_spec,
    s.id AS store_id,
    s.name AS store_name,
    r.id AS region_id,
    r.name AS region_name
FROM mission m
JOIN store s
    ON m.store_id = s.id
JOIN region r
    ON s.region_id = r.id
LEFT JOIN member_mission mm
    ON mm.mission_id = m.id
   AND mm.member_id = :memberId -- memberId
WHERE r.id = :regionId -- regionId
  AND mm.id IS NULL
ORDER BY m.deadline ASC, m.id DESC
LIMIT 15 OFFSET :offset;

--4. 마이 페이지 화면 쿼리
select
    m.name, m.email, m.point
from member m
where m.id= :memberId --memberId
