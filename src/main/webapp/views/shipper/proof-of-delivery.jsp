<%-- 
    Document   : proof-of-delivery
    Created on : Mar 6, 2026, 1:02:16 PM
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Xác nhận giao hàng - ClickEat Shipper</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script>
            tailwind.config = {
                theme: {
                    extend: {
                        fontFamily: {sans: ['Inter', 'sans-serif']},
                        colors: {primary: '#c86601', 'primary-dark': '#a05201'}
                    }
                }
            };
        </script>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <style>body { font-family: 'Inter', sans-serif; }</style>
    </head>
    <body class="bg-gray-900 flex justify-center min-h-screen">

        <div class="bg-white w-full max-w-md shadow-2xl flex flex-col h-screen relative overflow-hidden">

            <div class="bg-white px-4 py-4 flex items-center justify-between shadow-sm z-10 sticky top-0">
                <a href="javascript:history.back()" class="w-10 h-10 flex items-center justify-center text-gray-700 hover:bg-gray-100 rounded-full transition">
                    <i class="fa-solid fa-xmark text-xl"></i>
                </a>
                <h1 class="text-lg font-black text-gray-900">Chụp ảnh xác nhận</h1>
                <div class="w-10"></div>
            </div>

            <div class="flex-1 flex flex-col items-center justify-center p-6 bg-gray-50">

                <form action="${pageContext.request.contextPath}/shipper/proof" method="POST" enctype="multipart/form-data" class="w-full h-full flex flex-col" id="proofForm">
                    <input type="hidden" name="orderId" value="${orderId}">

                    <div class="flex-1 w-full flex flex-col items-center justify-center">
                        <div id="imagePreviewContainer" class="w-full h-80 bg-gray-200 rounded-3xl border-4 border-dashed border-gray-300 flex items-center justify-center relative overflow-hidden mb-6">
                            <img id="imagePreview" src="" class="absolute inset-0 w-full h-full object-cover hidden" alt="Bằng chứng giao hàng">
                            <div id="uploadPlaceholder" class="text-center text-gray-400">
                                <i class="fa-solid fa-camera text-6xl mb-3"></i>
                                <p class="font-bold">Bấm để chụp hoặc chọn ảnh</p>
                                <p class="text-xs mt-1">Ảnh chụp gói hàng tại cửa nhà khách</p>
                            </div>
                            <input type="file" id="proofImage" name="proofImage" accept="image/*" capture="environment" class="absolute inset-0 w-full h-full opacity-0 cursor-pointer" required>
                        </div>
                    </div>

                    <button type="submit" id="submitBtn" class="w-full bg-gray-300 text-gray-500 font-black text-lg py-4 rounded-xl transition cursor-not-allowed" disabled>
                        HOÀN TẤT GIAO HÀNG
                    </button>
                </form>

            </div>
        </div>

        <script>
            const imageInput = document.getElementById('proofImage');
            const imagePreview = document.getElementById('imagePreview');
            const uploadPlaceholder = document.getElementById('uploadPlaceholder');
            const submitBtn = document.getElementById('submitBtn');

            imageInput.addEventListener('change', function () {
                const file = this.files[0];
                if (file) {
                    const reader = new FileReader();
                    reader.onload = function (e) {
                        imagePreview.src = e.target.result;
                        imagePreview.classList.remove('hidden');
                        uploadPlaceholder.classList.add('hidden');
                        submitBtn.disabled = false;
                        // Kích hoạt nút submit
                        submitBtn.classList.remove('bg-gray-300', 'text-gray-500', 'cursor-not-allowed');
                        submitBtn.classList.add('bg-green-500', 'hover:bg-green-600', 'text-white', 'shadow-xl', 'cursor-pointer');
                    }
                    reader.readAsDataURL(file);
                }
            });
        </script>
    </body>
</html>
