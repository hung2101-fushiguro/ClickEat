import os
import codecs

sql_file = r"c:\Users\ASUS\Desktop\Subject_Project\ClickEat\db\seed_danang_plus_quangnam_old_250_compatible.sql"

with open(sql_file, 'rb') as f:
    raw_bytes = f.read()

text = None

# Attempt 1: Maybe it is just UTF-8 without BOM, but SSMS opened it as ANSI, which caused the user to see "MÃ¬ Quáº£ng".
# If the user saved it in SSMS, it might have literally saved the "MÃ¬ Quáº£ng" bytes.
# Let's check for double-encoded UTF-8.
try:
    decoded_utf8 = raw_bytes.decode('utf-8')
    # If it is double-encoded, `decoded_utf8` will contain "MÃ¬"
    if "MÃ¬" in decoded_utf8:
        print("Detected double-encoded UTF-8 (Mojibake). Fixing...")
        # Encode back to latin-1 to get the original bytes, then decode as utf-8
        text = decoded_utf8.encode('windows-1252').decode('utf-8')
    else:
        print("Detected normal UTF-8. Will just add BOM.")
        text = decoded_utf8
except UnicodeDecodeError:
    # Maybe it's utf-16 mixed or original utf-16?
    print("Not standard UTF-8. Attempting to parse mixed encoding or UTF-16.")
    pass

if text is None:
    # Attempt 2: Read ignoring errors, maybe it's utf-16?
    try:
        text = raw_bytes.decode('utf-16le')
        if "MÃ¬" in text:
            text = text.encode('windows-1252').decode('utf-8')
    except Exception as e:
        print("Failed UTF-16LE parse", e)
        # Fallback: brutal replacement
        text = raw_bytes.decode('utf-8', errors='replace')

# Specific fixes for the known mojibake just in case windows-1252 encode/decode fails due to mapped differences:
if "MÃ¬ Quáº£ng BÃ Mua" in text or "MÃ¬" in text:
    print("Manual fallback replacement for Mojibake triggered.")
    replacements = {
        "Ã¡": "á", "Ã ": "à", "Ã¢": "â", "Ã£": "ã", "áº¡": "ạ",
        "Ã¢y": "ây", "thá»‹t": "thịt", "Ä‘": "đ", "Ä": "Đ",
        "áº£": "ả", "Ã³": "ó", "Ã²": "ò", "á»": "ỏ", "Ã´": "ô", "á»™": "ộ",
        "Ãº": "ú", "Ã¹": "ù", "Ã½": "ý", "Ã¬": "ì", "Ã": "í",
        "MÃ¬": "Mì", "BÃ": "Bà", "Quáº£ng": "Quảng", "Cháº£": "Chả", "CÃ¡": "Cá", "Lá»¯": "Lữ",
        "BÃ¡nh": "Bánh", "XÃ¨o": "Xèo", "DÆ°á»¡ng": "Dưỡng", "TrÃ¡ng": "Tráng", "Cuá»‘n": "Cuốn",
        "Thá»‹t": "Thịt", "Tráº§n": "Trần", "CÆ¡m": "Cơm", "GÃ": "Gà", "Háº£i": "Hải",
        "MÃ": "Mì", "Máº¯m": "Mắm", "VÃ¢n": "Vân", "Sáº£n": "Sản", "BÃ©": "Bé", "Máº·n": "Mặn",
        "NiÃªu": "Niêu", "NhÃ": "Nhà", "Äá»": "Đỏ", "BÃ²": "Bò", "ThÆ°Æ¡ng": "Thương",
        "Báº¿p": "Bếp", "ÄÃ": "Đà", "Náºµng": "Nẵng", "BÃ¨o": "Bèo", "Gá»i": "Gỏi", "Ã”": "Ô",
        "Káº¹p": "Kẹp", "DÃ¬": "Dì", "ChÃ¨": "Chè", "Sáº§u": "Sầu", "LiÃªn": "Liên",
        "á»c": "Ốc", "Äiá»‡n": "Điện", "PhÆ°Æ¡ng": "Phương", "XÆ°Æ¡ng": "Xương", "HÃ": "Hà", "m": "m", # wait HÃ m = Hàm
        "LÃ": "Là", "ng": "ng", "NÆ°á»›ng": "Nướng", "Phá»Ÿ": "Phở", "Báº¯c": "Bắc", "Háº£i": "Hải",
        "Hoàn t¥t c­p nh­t": "Hoàn tất cập nhật",
        "100% hình £nh Ùc quyÁn DDG": "100% hình ảnh độc quyền DDG",
        "LÃ ng" : "Làng",
        "HÃ m" : "Hàm",
        "BÃ¬nh" : "Bình"
    }
    # For a purely programmatic fix, trying to encode back to cp1258 and decode to utf-8 is usually perfect
    try:
        text = text.encode('cp1252').decode('utf-8')
    except Exception as e:
        print("CP1252 fix failed:", e)
        for k, v in replacements.items():
            text = text.replace(k, v)

# Save the file cleanly as UTF-8 with BOM (utf-8-sig) which SQL Server Management Studio reads perfectly.
with open(sql_file, 'w', encoding='utf-8-sig') as f:
    f.write(text)

print("File has been re-encoded to UTF-8 with BOM.")
