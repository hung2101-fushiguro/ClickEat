import os
import urllib.request

out_dir = r"c:\Users\ASUS\Desktop\Subject_Project\ClickEat\src\main\webapp\assets\images"

images = {
    "real_food_mi_quang_ga_ta.jpg": "https://ik.imagekit.io/tvlk/dam/i/01kagbnw1r3kf67ey3fjn0nsx9.png?tr=q-70,c-at_max,w-1000,h-600",
    "real_food_cao_lau_hoi_an.jpg": "https://ik.imagekit.io/tvlk/dam/i/01kagf3ggq82z4nk2m3fm3k6hy.png?tr=q-70,c-at_max,w-1000,h-600",
    "real_food_be_thui_cau_mong.jpg": "https://static.vinwonders.com/2022/06/be-thui-cau-mong-1.jpg",
    "real_food_bun_mam_nem.jpg": "https://ik.imagekit.io/tvlk/dam/i/01kagd96rwbzrgnfhbtjdnx1n7.png?tr=q-70,c-at_max,w-1000,h-600",
    "real_food_banh_xeo_tom_nhay.jpg": "https://ik.imagekit.io/tvlk/dam/i/01kagde18eycznn8xky7dyyy02.png?tr=q-70,c-at_max,w-1000,h-600",
    "real_food_com_ga_hoi_an.jpg": "https://ik.imagekit.io/tvlk/blog/2023/09/am-thuc-hoi-an-1.jpg?tr=q-70,c-at_max,w-1000,h-600",
    "real_food_banh_trang_cuon_thit_heo.jpg": "https://ik.imagekit.io/tvlk/dam/i/01kagc5pt2rht6vxx6t12dmwnn.png?tr=q-70,c-at_max,w-1000,h-600",
    "real_food_nem_lui_nuong_sa.jpg": "https://ik.imagekit.io/tvlk/dam/i/01kagfeggw0mtp9tjs44anejkr.png?tr=q-70,c-at_max,w-1000,h-600",
    "real_food_banh_dap_hen_xao.jpg": "https://ik.imagekit.io/tvlk/dam/i/01kagf6x4gmnfx9ghq0r126f1m.png?tr=q-70,c-at_max,w-1000,h-600",
    "real_food_goi_ca_trich_nam_o.jpg": "https://ik.imagekit.io/tvlk/dam/i/01kagdfrj636xnkzsfppwt85aa.png?tr=q-70,c-at_max,w-1000,h-600",
    "real_food_pho_bo_tai_nam.jpg": "https://ik.imagekit.io/tvlk/blog/2022/10/pho-viet-nam-1.jpg?tr=q-70,c-at_max,w-1000,h-600",
    "real_food_bun_cha_ca_da_nang.jpg": "https://ik.imagekit.io/tvlk/dam/i/01kagdybrnx8q34gqr4fsas0re.png?tr=q-70,c-at_max,w-1000,h-600",
    "real_food_com_nieu_ca_bong_kho_to.jpg": "https://ik.imagekit.io/tvlk/dam/i/01kagfdy34pr5a8jbk586tvxst.png?tr=q-70,c-at_max,w-1000,h-600",
    "real_food_com_tam_suon_nuong.jpg": "https://ik.imagekit.io/tvlk/blog/2022/12/dac-san-sai-gon-6.jpg?tr=q-70,c-at_max,w-1000,h-600",
    "real_food_muc_mot_nang_nuong_sa_te.jpg": "https://static.vinwonders.com/2022/11/dac-san-phan-rang-10.jpg"
}

def download(filename, url):
    path = os.path.join(out_dir, filename)
    print(f"Downloading {filename}...")
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=20) as resp, open(path, 'wb') as f:
            f.write(resp.read())
        print(f"Success: {filename}")
    except Exception as e:
        print(f"Error {filename}: {e}")

for name, url in images.items():
    download(name, url)
