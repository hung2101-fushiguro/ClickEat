<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Tin nhắn – ClickEat Merchant</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script>
            tailwind.config = { theme: { extend: { colors: { primary: '#c86601' } } } };
        </script>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
        <style>
            body { font-family: 'Inter', sans-serif; }
            .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
            ::-webkit-scrollbar { width: 4px; } ::-webkit-scrollbar-track { background: transparent; } ::-webkit-scrollbar-thumb { background: #e5e7eb; border-radius: 2px; }
            .bounce1 { animation: bounce 1s infinite; }
            .bounce2 { animation: bounce 1s infinite 0.15s; }
            .bounce3 { animation: bounce 1s infinite 0.3s; }
            @keyframes bounce { 0%,80%,100%{transform:translateY(0)} 40%{transform:translateY(-6px)} }
        </style>
    </head>
    <body class="bg-gray-50 min-h-screen flex overflow-hidden" style="height:100vh">

        <%@ include file="_nav.jsp" %>

        <!-- Chat container — flex row, fills remaining space -->
        <div class="flex flex-1 min-h-0 bg-white overflow-hidden" id="chatContainer">

            <!-- ===== Conversation Sidebar ===== -->
            <div class="w-full md:w-80 shrink-0 border-r border-gray-200 flex flex-col bg-white" id="chatSidebar">
                <!-- Header -->
                <div class="px-4 py-4 border-b border-gray-100 flex items-center gap-3">
                    <h2 class="font-bold text-gray-900 text-base flex-1">Tin nhắn</h2>
                </div>
                <!-- Search -->
                <div class="p-3 border-b border-gray-100">
                    <div class="relative">
                        <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-[18px]">search</span>
                        <input type="text" id="searchInput" onkeyup="filterConversations(this.value)"
                        placeholder="Tìm tin nhắn..."
                        class="w-full pl-9 pr-4 py-2.5 bg-gray-50 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:bg-white transition-all border border-transparent focus:border-primary/30"/>
                    </div>
                </div>
                <!-- List -->
                <div class="flex-1 overflow-y-auto" id="convList"></div>
            </div>

            <!-- ===== Main Chat Area ===== -->
            <div class="hidden md:flex flex-1 flex-col min-h-0 min-w-0 bg-[#f8f7f5]" id="chatMain">
                <!-- Empty state -->
                <div id="emptyState" class="flex-1 flex flex-col items-center justify-center text-gray-400 bg-white">
                    <div class="w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center mb-4">
                        <span class="material-symbols-outlined text-4xl opacity-40">chat_bubble</span>
                    </div>
                    <p class="font-semibold text-gray-500">Chọn một cuộc hội thoại để bắt đầu</p>
                </div>
                <!-- Active chat (hidden until conversation selected) -->
                <div id="activeChatArea" class="hidden flex-1 flex flex-col min-h-0">
                    <!-- Chat Header -->
                    <div class="bg-white/90 backdrop-blur border-b border-gray-200 px-4 md:px-6 py-3 flex items-center justify-between shrink-0">
                        <div class="flex items-center gap-3">
                            <button class="md:hidden p-1 -ml-1 rounded-full hover:bg-gray-100" onclick="backToList()">
                                <span class="material-symbols-outlined text-gray-500">arrow_back</span>
                            </button>
                            <div class="relative">
                                <img id="chatHeaderAvatar" src="" class="w-10 h-10 rounded-full object-cover border border-gray-200 shadow-sm"/>
                                <span id="chatHeaderOnline" class="hidden absolute bottom-0 right-0 w-3 h-3 bg-green-500 border-2 border-white rounded-full"></span>
                            </div>
                            <div>
                                <h3 id="chatHeaderName" class="font-semibold text-gray-900 text-base leading-tight"></h3>
                                <p id="chatHeaderRole" class="text-xs text-gray-500 font-medium"></p>
                            </div>
                        </div>
                        <div class="flex gap-1">
                            <button class="w-10 h-10 rounded-full bg-gray-50 hover:bg-gray-100 flex items-center justify-center text-primary transition-colors">
                                <span class="material-symbols-outlined text-[20px]">call</span>
                            </button>
                            <button class="w-10 h-10 rounded-full bg-gray-50 hover:bg-gray-100 flex items-center justify-center text-gray-500 transition-colors">
                                <span class="material-symbols-outlined text-[20px]">more_vert</span>
                            </button>
                        </div>
                    </div>
                    <!-- Messages -->
                    <div class="flex-1 overflow-y-auto px-4 py-4 space-y-3" id="messagesList">
                        <div class="text-center mb-4">
                            <span class="text-[10px] font-semibold text-gray-500 bg-gray-200 px-3 py-1 rounded-full uppercase tracking-wider">Hôm nay</span>
                        </div>
                    </div>
                    <!-- Typing indicator -->
                    <div id="typingIndicator" class="hidden px-4 pb-2">
                        <div class="flex items-end gap-2">
                            <img id="typingAvatar" src="" class="w-6 h-6 rounded-full object-cover border border-gray-200"/>
                            <div class="bg-white px-4 py-3 rounded-[20px] rounded-bl-sm shadow-sm">
                                <div class="flex gap-1">
                                    <div class="w-2 h-2 bg-gray-400 rounded-full bounce1"></div>
                                    <div class="w-2 h-2 bg-gray-400 rounded-full bounce2"></div>
                                    <div class="w-2 h-2 bg-gray-400 rounded-full bounce3"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- Input bar -->
                    <div class="px-3 py-3 bg-white border-t border-gray-200 shrink-0">
                        <form onsubmit="sendMessage(event)" class="flex items-end gap-1.5">
                            <button type="button" class="p-2 text-gray-400 hover:text-primary hover:bg-gray-50 rounded-full shrink-0">
                                <span class="material-symbols-outlined">add_circle</span>
                            </button>
                            <button type="button" class="p-2 text-gray-400 hover:text-primary hover:bg-gray-50 rounded-full hidden md:block">
                                <span class="material-symbols-outlined">image</span>
                            </button>
                            <div class="flex-1 bg-gray-100 border border-transparent rounded-3xl px-5 py-3 focus-within:bg-white focus-within:border-primary/50 focus-within:ring-4 focus-within:ring-primary/10 transition-all">
                                <input type="text" id="msgInput" placeholder="Nhập tin nhắn..."
                                class="w-full bg-transparent border-none outline-none text-sm text-gray-900 placeholder:text-gray-500 font-medium"/>
                            </div>
                            <button type="submit"
                            class="p-2.5 bg-primary text-white rounded-full shadow-lg shadow-primary/30 hover:bg-orange-600 hover:scale-110 active:scale-95 transition-all flex items-center justify-center shrink-0 disabled:opacity-50">
                            <span class="material-symbols-outlined">send</span>
                        </button>
                    </form>
                    <!-- Quick replies -->
                    <div class="flex gap-2 mt-2.5 overflow-x-auto pb-0.5 px-1" style="-ms-overflow-style:none;scrollbar-width:none">
                        <button onclick="setQuick('Đơn hàng của bạn đã sẵn sàng!')" class="px-3 py-1.5 bg-gray-50 border border-gray-200 rounded-full text-xs font-semibold text-gray-600 hover:bg-primary/10 hover:text-primary hover:border-primary whitespace-nowrap transition-colors">Đơn hàng của bạn đã sẵn sàng!</button>
                        <button onclick="setQuick('Cảm ơn bạn đã đặt hàng.')" class="px-3 py-1.5 bg-gray-50 border border-gray-200 rounded-full text-xs font-semibold text-gray-600 hover:bg-primary/10 hover:text-primary hover:border-primary whitespace-nowrap transition-colors">Cảm ơn bạn đã đặt hàng.</button>
                        <button onclick="setQuick('Xin lỗi vì sự chậm trễ.')" class="px-3 py-1.5 bg-gray-50 border border-gray-200 rounded-full text-xs font-semibold text-gray-600 hover:bg-primary/10 hover:text-primary hover:border-primary whitespace-nowrap transition-colors">Xin lỗi vì sự chậm trễ.</button>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <script>
        // ---- Data ----
        let conversations = [
        {id:1,name:'Nguyễn Văn A',role:'Khách hàng',avatar:'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=60',lastMsg:'Cho mình xin thêm tương ớt nha shop',time:'12:30',unread:1,isOnline:true,
        messages:[
        {id:1,text:'Chào bạn, đơn hàng của mình sắp xong chưa ạ?',sender:'other',time:'12:28'},
        {id:2,text:'Dạ chào bạn, bếp đang chuẩn bị rồi ạ. Tầm 5 phút nữa là xong nhé.',sender:'me',time:'12:29'},
        {id:3,text:'Tuyệt vời. Cho mình xin thêm tương ớt nha shop.',sender:'other',time:'12:30'},
        ]},
        {id:2,name:'Trần Văn Tài',role:'Tài xế',avatar:'https://images.unsplash.com/photo-1633332755192-727a05c4013d?auto=format&fit=crop&w=100&q=60',lastMsg:'Tôi đang đợi ở trước quán nhé',time:'12:15',unread:2,isOnline:false,
        messages:[
        {id:1,text:'Alo quán ơi, đơn #CE-4820 xong chưa?',sender:'other',time:'12:10'},
        {id:2,text:'Đang gói bạn ơi, 2 phút nữa nha.',sender:'me',time:'12:12'},
        {id:3,text:'Tôi đang đợi ở trước quán nhé',sender:'other',time:'12:15'},
        ]},
        {id:3,name:'Lê Hoàng C',role:'Khách hàng',avatar:'https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=100&q=60',lastMsg:'Cảm ơn shop nhiều!',time:'Hôm qua',unread:0,isOnline:false,
        messages:[
        {id:1,text:'Món ăn rất ngon, mình sẽ đánh giá 5 sao.',sender:'other',time:'19:45'},
        {id:2,text:'Cảm ơn bạn nhiều ạ! Mong bạn ủng hộ lần sau nhé.',sender:'me',time:'19:50'},
        {id:3,text:'Cảm ơn shop nhiều!',sender:'other',time:'20:00'},
        ]},
        ];
        let activeChatId = null;
        let isTyping = false;
        
        // ---- Render conversation list ----
        function renderList(list) {
            const el = document.getElementById('convList');
            el.innerHTML = (list||conversations).map(c => {
                const activeClass  = activeChatId === c.id ? 'bg-orange-50/50 border-primary' : 'border-transparent';
                const nameClass    = c.unread > 0 ? 'font-bold text-gray-900' : 'font-semibold text-gray-700';
                const msgClass     = c.unread > 0 ? 'text-gray-900 font-semibold' : 'text-gray-500';
                const onlineDot    = c.isOnline ? '<span class="absolute bottom-0 right-0 w-3.5 h-3.5 bg-green-500 border-2 border-white rounded-full"></span>' : '';
                const badge        = c.unread > 0 ? '<span class="ml-2 bg-primary text-white text-[10px] font-bold px-1.5 py-0.5 rounded-full min-w-[18px] text-center">' + c.unread + '</span>' : '';
                const motoPrefix   = c.role === 'Tài xế' ? '🛵 ' : '';
                return `
                <div onclick="selectChat(\${c.id})"
                class="p-4 flex gap-3 cursor-pointer hover:bg-gray-50 transition-colors border-l-4 \${activeClass}">
                <div class="relative shrink-0">
                <img src="\${c.avatar}" alt="\${c.name}" class="w-12 h-12 rounded-full object-cover border border-gray-200"/>
                \${onlineDot}
                </div>
                <div class="flex-1 min-w-0">
                <div class="flex justify-between items-start mb-0.5">
                <h4 class="text-sm truncate \${nameClass}">\${c.name}</h4>
                <span class="text-[10px] text-gray-400 shrink-0 ml-2">\${c.time}</span>
                </div>
                <div class="flex justify-between items-center">
                <p class="text-xs truncate \${msgClass}">\${motoPrefix}\${c.lastMsg}</p>
                \${badge}
                </div>
                </div>
                </div>`;
            }).join('');
        }
        
        // ---- Open a chat ----
        function selectChat(id) {
            activeChatId = id;
            conversations = conversations.map(c => c.id===id ? {...c, unread:0} : c);
            renderList();
            renderMessages();
            
            const conv = conversations.find(c=>c.id===id);
            document.getElementById('chatHeaderAvatar').src = conv.avatar;
            document.getElementById('chatHeaderName').textContent = conv.name;
            document.getElementById('chatHeaderRole').innerHTML = (conv.isOnline?'<span class="inline-block w-1.5 h-1.5 bg-green-500 rounded-full mr-1"></span>':'') + conv.role;
            document.getElementById('chatHeaderOnline').classList.toggle('hidden', !conv.isOnline);
            document.getElementById('typingAvatar').src = conv.avatar;
            
            document.getElementById('emptyState').classList.add('hidden');
            document.getElementById('activeChatArea').classList.remove('hidden');
            document.getElementById('activeChatArea').classList.add('flex');
            
            const isMobile = window.innerWidth < 768;
            if(isMobile) {
                document.getElementById('chatSidebar').classList.add('hidden');
                document.getElementById('chatMain').classList.remove('hidden');
                document.getElementById('chatMain').classList.add('flex');
            }
            scrollBottom();
        }
        
        function renderMessages() {
            const conv = conversations.find(c=>c.id===activeChatId);
            if(!conv) return;
            const el = document.getElementById('messagesList');
            // keep date badge
            el.innerHTML = `<div class="text-center mb-4"><span class="text-[10px] font-semibold text-gray-500 bg-gray-200 px-3 py-1 rounded-full uppercase tracking-wider">Hôm nay</span></div>`;
            conv.messages.forEach(msg => appendMsgEl(msg, conv.avatar));
            scrollBottom();
        }
        
        function appendMsgEl(msg, avatar) {
            const el    = document.getElementById('messagesList');
            const isMe  = msg.sender === 'me';
            const alignClass  = isMe ? 'justify-end pr-4' : 'justify-start items-end pl-4';
            const bubbleClass = isMe
            ? 'bg-primary text-white rounded-[20px] rounded-br-sm'
            : 'bg-white text-gray-900 rounded-[20px] rounded-bl-sm';
            const timeColor     = isMe ? 'text-white/80' : 'text-gray-400';
            const avatarImg     = !isMe ? `<img src="\${avatar}" class="w-6 h-6 rounded-full mb-1 mr-2 object-cover border border-gray-200"/>` : '';
            const readIndicator = isMe ? '<span class="material-symbols-outlined text-[12px]" style="font-variation-settings:\'FILL\' 0">done_all</span>' : '';
            const div = document.createElement('div');
            div.className = `flex w-full group \${alignClass}`;
            div.innerHTML = `\${avatarImg}<div class="max-w-[68%] md:max-w-[60%] px-4 py-3 shadow-sm relative text-[14px] transition-all hover:shadow-md leading-relaxed \${bubbleClass}">
            <p>\${msg.text}</p>
            <div class="flex items-center justify-end gap-1 mt-1 opacity-70 \${timeColor}">
            <span class="text-[10px] font-medium">\${msg.time}</span>
            \${readIndicator}
            </div>
            </div>`;
            el.appendChild(div);
        }
        
        // ---- Send message ----
        function sendMessage(e) {
            e && e.preventDefault();
            const input = document.getElementById('msgInput');
            const text = input.value.trim();
            if(!text || !activeChatId) return;
            const time = new Date().toLocaleTimeString('vi-VN',{hour:'2-digit',minute:'2-digit'});
            const msg = {id: Date.now(), text, sender:'me', time};
            const conv = conversations.find(c=>c.id===activeChatId);
            conv.messages.push(msg);
            conv.lastMsg = text; conv.time = 'Vừa xong';
            appendMsgEl(msg, conv.avatar);
            input.value = '';
            renderList();
            scrollBottom();
            // Simulate reply
            setTimeout(() => {
                document.getElementById('typingIndicator').classList.remove('hidden');
                scrollBottom();
                setTimeout(() => {
                    const replyTime = new Date().toLocaleTimeString('vi-VN',{hour:'2-digit',minute:'2-digit'});
                    const reply = {id:Date.now()+1, text:'Cảm ơn shop nhé! 🥰', sender:'other', time:replyTime};
                    conv.messages.push(reply);
                    conv.lastMsg = reply.text; conv.time='Vừa xong';
                    document.getElementById('typingIndicator').classList.add('hidden');
                    appendMsgEl(reply, conv.avatar);
                    renderList();
                    scrollBottom();
                }, 2000);
            }, 1000);
        }
        
        function setQuick(text) { document.getElementById('msgInput').value = text; document.getElementById('msgInput').focus(); }
        
        function scrollBottom() {
            const el = document.getElementById('messagesList');
            el.scrollTop = el.scrollHeight;
        }
        
        function backToList() {
            activeChatId = null;
            document.getElementById('chatSidebar').classList.remove('hidden');
            document.getElementById('chatMain').classList.add('hidden');
            document.getElementById('chatMain').classList.remove('flex');
            renderList();
        }
        
        function filterConversations(q) {
            const lq = q.toLowerCase();
            const filtered = q ? conversations.filter(c => c.name.toLowerCase().includes(lq) || c.lastMsg.toLowerCase().includes(lq)) : conversations;
            renderList(filtered);
        }
        
        // Handle mobile resize
        window.addEventListener('resize', () => {
            if(window.innerWidth >= 768) {
                document.getElementById('chatSidebar').classList.remove('hidden');
                document.getElementById('chatMain').classList.remove('hidden');
                document.getElementById('chatMain').classList.add('flex');
            }
        });
        
        // ---- Initial render ----
        renderList();
        // Auto-select first on desktop
        if(window.innerWidth >= 768) selectChat(1);
    </script>
</body>
</html>
