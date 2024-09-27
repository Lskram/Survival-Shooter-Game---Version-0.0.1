---

# 🎯 **Survival Shooter Game** - *Version 0.0.1*

> **แนวเกม:** Top-down shooter + Roguelike  
> **สถานะการพัฒนา:** Early Development

---

## 🎮 **แนวคิดหลักของเกม**  
- 🔫 **เกมยิง** แนว *Top-down Shooter* ผสมกับระบบ **Roguelike**  
- 👾 **ศัตรูจำนวนมาก** จะเข้ามาโจมตีผู้เล่นในรูปแบบเวฟ  
- 💥 **เน้นอัพเกรดสกิล** และ **การเลือกสกิล** เพื่อความแข็งแกร่งในการเอาชีวิตรอด

---

## 🕹️ **ระบบการเล่น**

### 1. 🧭 **การควบคุม**  
- 🔄 เคลื่อนที่ด้วยปุ่ม `W, A, S, D`  
- 🎯 ยิงอัตโนมัติไปยังตำแหน่งเมาส์  
- ⚡ กดตัวเลข `1-9` เพื่อใช้ **สกิล** ต่างๆ

### 2. 🌊 **ระบบเวฟศัตรู**  
- 💀 **ศัตรู** จะเกิดขึ้นเป็นเวฟต่อเนื่อง  
- ⚔️ ทุกๆ 10 เวฟ **ความยากจะเพิ่มขึ้น**  
- 🚶‍♂️ ศัตรู **วิ่งเข้าหา** ผู้เล่นโดยตรง

### 3. 🧟 **ระบบบอส**  
- 👹 บอสเกิดทุกๆ **20 ศัตรูที่ถูกกำจัด**  
- 💪 บอสมีพลังชีวิตและความแข็งแกร่งมากกว่าศัตรูทั่วไป

### 4. 🎁 **ระบบไอเทม**  
- 🔄 **ดร็อปไอเทม** จากศัตรูที่ถูกกำจัด  
- 💖 ไอเทมฟื้นฟูพลังชีวิต และ ⚔️ เพิ่มพลังโจมตีชั่วคราว

### 5. 🌀 **ระบบสกิล**  
- ⚡ มีสกิลทั้งหมด **19 แบบ** (Active & Passive)  
- 🎮 ใช้สกิล Active โดยกดปุ่มที่กำหนด มี **Cooldown**  
- 🛡️ สกิล Passive ทำงาน **อัตโนมัติ** เพื่อเพิ่มความสามารถให้ตัวละคร  
- 🚀 ผู้เล่นสามารถ **เลือกสกิลใหม่** เมื่อขึ้นเลเวล

### 6. 📈 **ระบบเลเวลและ EXP**  
- 🏆 ได้รับ **EXP** เมื่อกำจัดศัตรู  
- ✨ เมื่อขึ้นเลเวลสามารถ **เลือกสกิลใหม่** ได้

### 7. ⚔️ **ระบบความยาก**  
- 🎮 ความยากจะเพิ่มขึ้นตามจำนวนเวฟที่ผ่านไป  
- 🏃‍♂️ ศัตรูจะมี **พลังชีวิต** และ **ความเร็วเพิ่มขึ้น** ทุกเวฟ

---

## 🖼️ **กราฟิกและ UI**  
- 🔲 ใช้ **รูปทรงเรขาคณิตพื้นฐาน** (สี่เหลี่ยม, วงกลม)  
- 📊 แสดงแถบ **พลังชีวิต**, **EXP**, **เลเวล**, **เวฟปัจจุบัน**, และ **เวลาที่เอาชีวิตรอด**  
- 💡 แสดง **สถานะสกิล** และ **Cooldown**

---

## ⚙️ **ระบบการตั้งค่า (Planned Features)**  
- ⚙️ กำลังวางแผนสำหรับการตั้งค่าต่างๆ เช่น ความละเอียดหน้าจอและคุณภาพกราฟิก

---

## 🏅 **ระบบคะแนนและ High Score**  
- 🕒 บันทึก **เวลาที่เอาชีวิตรอด**  
- 🎯 แสดง **เลเวลสูงสุด** เมื่อเกม **Game Over**

---

## 🛠️ **การพัฒนาในอนาคต**  
- 🎨 ปรับปรุง **กราฟิก** ให้สวยงามขึ้น  
- 🎶 เพิ่ม **เสียง** และ **ดนตรีประกอบ**  
- ⚔️ เพิ่มความหลากหลายของ **ศัตรูและบอส**  
- 🏆 เพิ่มระบบ **Achievement และ Leaderboard**

---

## 🚀 **การติดตั้งและการรันเกม**

1. **ติดตั้ง Love2D**  
   - ดาวน์โหลดและติดตั้ง Love2D ได้จากเว็บไซต์ [love2d.org](https://love2d.org/)

2. **Clone โค้ดเกมจาก GitHub**  
   ```bash
   git clone https://github.com/Lskram/Survival-Shooter-Game---Version-0.0.1.git
   cd survival-shooter
   ```

3. **รันเกมด้วยคำสั่ง Love2D**  
   ```bash
   love .
   ```

4. **เพลิดเพลินไปกับการยิงและการเอาชีวิตรอด!** 🎮💥

---

## 📝 **สรุป**  
🎯 **Survival Shooter Game - Version 0.0.1** เป็นเวอร์ชันเริ่มต้นที่มีระบบพื้นฐานครบถ้วน แต่ยังต้องการการพัฒนาเพิ่มเติม เช่น การปรับสมดุล, เพิ่มกราฟิก และฟีเจอร์ใหม่ๆ ที่จะทำให้เกมสนุกและท้าทายมากขึ้น! 🎮

---
