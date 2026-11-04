# WorkMatch AI Job Finder

เว็บไซต์ค้นหางานและจับคู่งานเบื้องต้นด้วย JavaScript พร้อมเชื่อม Supabase ได้

## สิ่งที่มีในชุดนี้
- ค้นหาจากตำแหน่งงาน ทักษะ/คีย์เวิร์ด จังหวัด อายุ ประเภทงาน ประสบการณ์ และเงินเดือนขั้นต่ำ
- คะแนน AI Matching แบบ weighted keyword matching พร้อมเหตุผลพื้นฐานจากคำที่ตรงกัน
- เรียงผลลัพธ์ตามคะแนน เงินเดือน หรือวันที่ประกาศ
- ดูรายละเอียดงานและเปิดลิงก์สมัครงาน
- บันทึกงานที่สนใจและติดตามสถานะการสมัคร
- สมัครสมาชิก/เข้าสู่ระบบด้วย Supabase Auth (เมื่อกำหนดค่า)
- โหมดทดลองใช้ข้อมูลตัวอย่างโดยไม่ต้องมี Supabase
- Responsive design และ Dark mode

## เริ่มใช้งานแบบทดลอง
1. แตกไฟล์ ZIP
2. เปิดโฟลเดอร์ใน VS Code
3. เปิด Terminal ที่โฟลเดอร์โปรเจกต์
4. รัน `npx serve .` หรือใช้ส่วนขยาย Live Server
5. เปิด URL ที่แสดงใน Terminal

หากไม่มี Node.js ให้ติดตั้ง Node.js LTS ก่อน หรือเปิด `index.html` โดยตรงเพื่อทดลองเบื้องต้น (แนะนำ local server)

## เชื่อม Supabase
1. สร้าง Supabase Project
2. เปิด SQL Editor แล้วรันไฟล์ `supabase-schema.sql`
3. ไปที่ Project Settings > API แล้วคัดลอก Project URL และ Publishable key (หรือ legacy anon key)
4. ใส่ค่าใน `config.js`:
   ```js
   window.APP_CONFIG = {
     SUPABASE_URL: "https://YOUR_PROJECT.supabase.co",
     SUPABASE_ANON_KEY: "YOUR_PUBLISHABLE_OR_ANON_KEY"
   };
   ```
5. อย่าใส่ `service_role` หรือ Secret key ลงใน browser code, GitHub หรือไฟล์ที่เผยแพร่
6. รีเฟรชเว็บ ระบบจะโหลดประกาศงานจาก `public.jobs` ถ้ามีข้อมูลที่ active

## เพิ่มประกาศงาน
ตาราง `jobs` อ่านได้เฉพาะประกาศที่ `is_active = true` ผ่าน public policy
การเพิ่ม/แก้ไขประกาศต้องทำผ่าน trusted admin process เช่น Supabase Dashboard/SQL Editor หรือ backend ที่ตรวจสอบสิทธิ์แล้ว ห้ามเปิด policy ให้ผู้ใช้ทั่วไปเขียนตาราง jobs

ตัวอย่าง SQL สำหรับเพิ่มงาน (แก้รายละเอียดและ URL เป็นข้อมูลจริงที่ตรวจสอบแล้ว):
```sql
insert into public.jobs
(title, company_name, province, description, requirements, keywords,
 salary_min, salary_max, job_type, experience_level, apply_url, source_url, is_active)
values
('Graphic Designer', 'Example Company', 'กรุงเทพมหานคร',
 'รายละเอียดงาน', 'คุณสมบัติ', array['Photoshop','Illustrator'],
 18000, 28000, 'Full-Time', 'นักศึกษาจบใหม่',
 'https://company.example/careers', 'https://company.example/careers', true);
```

## ขอบเขตที่ควรรู้
- ข้อมูลใน demo เป็นข้อมูลจำลองเพื่อทดสอบหน้าตาและระบบเท่านั้น ไม่ใช่ตำแหน่งงานที่ยืนยันว่ากำลังเปิดรับ
- คะแนน Matching เป็นการจับคู่คำและตัวกรองในเบราว์เซอร์ ไม่ใช่โมเดล AI ที่ผ่านการฝึก และไม่รับประกันการได้งาน
- เว็บไซต์นี้ยังไม่ได้เชื่อม API ผู้ให้บริการประกาศงานหรือ crawler ดังนั้นจะไม่ดึงงานสดจากเว็บภายนอกโดยอัตโนมัติ
- ลิงก์ในข้อมูลตัวอย่างเป็นลิงก์หน้าแพลตฟอร์มค้นหางานทั่วไป ไม่ใช่การยืนยันว่าบริษัทตัวอย่างมีตำแหน่งนั้นเปิดรับ
- ก่อนใช้งานจริง ให้ import ประกาศงานที่ได้รับอนุญาตและตรวจสอบ `apply_url` ว่าเป็นหน้าสมัครอย่างเป็นทางการของบริษัท
- อายุใช้สำหรับแสดง/ตรวจสอบเงื่อนไขที่นายจ้างประกาศเท่านั้น ไม่ควรใช้เป็นตัวตัดสินความสามารถของผู้สมัคร

## โครงสร้างไฟล์
- `index.html` — หน้าเว็บและองค์ประกอบ UI
- `styles.css` — ธีมและ Responsive Design
- `app.js` — ค้นหา, matching, saved jobs, application tracker, auth
- `config.js` — ค่าการเชื่อมต่อ Supabase (ไม่มี secret)
- `supabase-schema.sql` — ตารางและ RLS policies
