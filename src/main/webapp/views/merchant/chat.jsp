<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Tin nhắn – ClickEat Merchant</title>

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

        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet"/>

        <style>
            body{
                font-family:'Inter',sans-serif;
                height:100vh;
                overflow:hidden;
            }

            ::-webkit-scrollbar{
                width:4px;
            }

            ::-webkit-scrollbar-thumb{
                background:#e5e7eb;
                border-radius:2px;
            }

            #messagesList{
                scroll-behavior:smooth;
            }
        </style>
    </head>

    <body class="bg-gray-50 flex overflow-hidden">

        <%@ include file="_nav.jsp" %>

        <div class="flex flex-1 min-h-0 bg-white overflow-hidden">

            <!-- SIDEBAR -->
            <div class="w-full md:w-80 shrink-0 border-r border-gray-200 flex flex-col bg-white">

                <div class="px-4 py-4 border-b border-gray-100">
                    <h2 class="font-bold text-gray-900 text-base">Tin nhắn</h2>
                </div>

                <c:if test="${not empty chatInfo}">
                    <div class="mx-3 mt-3 px-3 py-2 rounded-lg bg-amber-50 border border-amber-200 text-amber-700 text-xs font-medium">
                        ${chatInfo}
                    </div>
                </c:if>

                <div class="flex-1 overflow-y-auto">

                    <c:choose>

                        <c:when test="${empty conversations}">
                            <div class="p-8 text-center text-gray-400 text-sm italic">
                                Chưa có tin nhắn nào
                            </div>
                        </c:when>

                        <c:otherwise>

                            <c:forEach var="c" items="${conversations}">

                                <a href="${pageContext.request.contextPath}/merchant/chat?with=${c.senderId}"
                                   class="p-4 flex gap-3 hover:bg-gray-50 transition border-l-4
                                   ${activeWithId == c.senderId ? 'bg-orange-50 border-primary' : 'border-transparent'}">

                                    <div class="relative shrink-0">

                                        <img
                                            src="${not empty c.otherPartyAvatar
                                                   ? c.otherPartyAvatar
                                                   : 'https://ui-avatars.com/api/?name='.concat(c.otherPartyName)}"

                                            class="w-12 h-12 rounded-full object-cover border border-gray-200"/>

                                    </div>

                                    <div class="flex-1 min-w-0">

                                        <div class="flex justify-between items-start mb-1">

                                            <h4 class="text-sm truncate font-bold text-gray-900">
                                                ${c.otherPartyName}
                                            </h4>

                                            <span class="text-[10px] text-gray-400">
                                                <fmt:formatDate value="${c.createdAt}" pattern="HH:mm"/>
                                            </span>

                                        </div>

                                        <p class="text-xs truncate text-gray-500">
                                            ${c.content}
                                        </p>

                                    </div>

                                </a>

                            </c:forEach>

                        </c:otherwise>

                    </c:choose>

                </div>

            </div>


            <!-- CHAT MAIN -->
            <div class="flex-1 flex flex-col min-h-0 bg-[#f8f7f5]">

                <c:choose>

                    <c:when test="${empty activeWithId}">

                        <div class="flex-1 flex flex-col items-center justify-center text-gray-400 bg-white">

                            <span class="material-symbols-outlined text-4xl opacity-40 mb-4">
                                chat_bubble
                            </span>

                            <p class="font-semibold text-gray-500">
                                Chọn một cuộc hội thoại để bắt đầu
                            </p>

                        </div>

                    </c:when>

                    <c:otherwise>

                        <!-- HEADER -->
                        <div class="bg-white border-b border-gray-200 px-6 py-3">
                            <h3 class="font-semibold text-gray-900">
                                Hội thoại trực tuyến
                            </h3>
                        </div>


                        <!-- MESSAGE LIST -->
                            <div class="flex-1 overflow-y-auto px-4 py-4 space-y-4"
                                id="messagesList"
                                data-context-path="${pageContext.request.contextPath}"
                                data-active-with="${activeWithId}"
                                data-current-user="${account.id}">

                            <c:forEach var="m" items="${history}">

                                  <div class="flex w-full ${m.senderId == account.id ? 'justify-end' : 'justify-start'}"
                                      data-message-id="${m.id}"
                                      data-sender-id="${m.senderId}">

                                    <div class="max-w-[70%] px-4 py-3 shadow-sm text-[14px]
                                         ${m.senderId == account.id
                                           ? 'bg-primary text-white rounded-[20px] rounded-br-sm'
                                           : 'bg-white text-gray-900 rounded-[20px] rounded-bl-sm'}">

                                        <p>${m.content}</p>

                                        <div class="flex items-center justify-end gap-1 mt-1 opacity-70 text-[10px]">
                                            <fmt:formatDate value="${m.createdAt}" pattern="HH:mm"/>
                                        </div>

                                    </div>

                                </div>

                            </c:forEach>

                        </div>


                        <!-- INPUT -->
                        <div class="px-3 py-3 bg-white border-t border-gray-200">

                                <form method="POST"
                                    id="chatForm"
                                  action="${pageContext.request.contextPath}/merchant/chat"
                                  class="flex items-end gap-2">

                                <input type="hidden" id="receiverId" name="receiverId" value="${activeWithId}"/>

                                <div class="flex-1 bg-gray-100 rounded-3xl px-5 py-3 focus-within:bg-white focus-within:ring-2 focus-within:ring-primary/20 transition">

                                    <input type="text"
                                           name="message"
                                           id="msgInput"
                                           placeholder="Nhập tin nhắn..."
                                           required
                                           autocomplete="off"
                                           autofocus
                                           class="w-full bg-transparent border-none outline-none text-sm text-gray-900"/>

                                </div>

                                <button type="submit"
                                        class="p-2.5 bg-primary text-white rounded-full hover:bg-orange-600 transition">

                                    <span class="material-symbols-outlined">
                                        send
                                    </span>

                                </button>

                            </form>

                        </div>

                    </c:otherwise>

                </c:choose>

            </div>

        </div>


        <script>
            function scrollToBottom() {
                const el = document.getElementById("messagesList");
                if (el) {
                    el.scrollTop = el.scrollHeight;
                }
            }

            function escapeHtml(text) {
                return String(text || "")
                        .replace(/&/g, "&amp;")
                        .replace(/</g, "&lt;")
                        .replace(/>/g, "&gt;")
                        .replace(/\"/g, "&quot;")
                        .replace(/'/g, "&#39;");
            }

            function createMessageNode(message, currentUserId) {
                const mine = Number(message.senderId) === Number(currentUserId);
                const row = document.createElement("div");
                row.className = "flex w-full " + (mine ? "justify-end" : "justify-start");
                row.dataset.messageId = String(message.id || 0);
                row.dataset.senderId = String(message.senderId || 0);

                const bubble = document.createElement("div");
                bubble.className = "max-w-[70%] px-4 py-3 shadow-sm text-[14px] "
                        + (mine
                                ? "bg-primary text-white rounded-[20px] rounded-br-sm"
                                : "bg-white text-gray-900 rounded-[20px] rounded-bl-sm");

                const content = document.createElement("p");
                content.innerHTML = escapeHtml(message.content);

                const time = document.createElement("div");
                time.className = "flex items-center justify-end gap-1 mt-1 opacity-70 text-[10px]";
                time.textContent = message.time || "";

                bubble.appendChild(content);
                bubble.appendChild(time);
                row.appendChild(bubble);
                return row;
            }

            (function initMerchantChatRealtime() {
                const listEl = document.getElementById("messagesList");
                const formEl = document.getElementById("chatForm");
                const inputEl = document.getElementById("msgInput");
                const receiverEl = document.getElementById("receiverId");

                if (!listEl || !formEl || !inputEl || !receiverEl || !receiverEl.value) {
                    scrollToBottom();
                    return;
                }

                const contextPath = listEl.dataset.contextPath || "";
                const currentUserId = Number(listEl.dataset.currentUser || "0");
                const withId = receiverEl.value;
                const endpoint = contextPath + "/merchant/chat/realtime";

                const lastRendered = listEl.querySelector("[data-message-id]:last-of-type");
                let lastMessageId = lastRendered ? Number(lastRendered.dataset.messageId || "0") : 0;
                let sending = false;

                async function fetchNewMessages() {
                    try {
                        const res = await fetch(endpoint + "?with=" + encodeURIComponent(withId) + "&since=" + encodeURIComponent(lastMessageId), {
                            credentials: "same-origin"
                        });
                        if (!res.ok) {
                            return;
                        }
                        const data = await res.json();
                        if (data && data.error === "chat_closed") {
                            window.location.href = contextPath + "/merchant/chat";
                            return;
                        }
                        if (!data || !data.success || !Array.isArray(data.messages) || data.messages.length === 0) {
                            return;
                        }

                        data.messages.forEach(function (message) {
                            if (Number(message.id || 0) <= lastMessageId) {
                                return;
                            }
                            const node = createMessageNode(message, currentUserId);
                            listEl.appendChild(node);
                            lastMessageId = Math.max(lastMessageId, Number(message.id || 0));
                        });

                        scrollToBottom();
                    } catch (e) {
                    }
                }

                formEl.addEventListener("submit", async function (event) {
                    event.preventDefault();
                    if (sending) {
                        return;
                    }

                    const message = (inputEl.value || "").trim();
                    if (!message) {
                        return;
                    }

                    sending = true;
                    try {
                        const body = new URLSearchParams();
                        body.set("with", withId);
                        body.set("message", message);

                        const res = await fetch(endpoint, {
                            method: "POST",
                            credentials: "same-origin",
                            headers: {
                                "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
                            },
                            body: body.toString()
                        });

                        if (!res.ok) {
                            throw new Error("send-failed");
                        }

                        const data = await res.json();
                        if (data && data.error === "chat_closed") {
                            window.location.href = contextPath + "/merchant/chat";
                            return;
                        }
                        if (data && data.success && Array.isArray(data.messages) && data.messages.length > 0) {
                            data.messages.forEach(function (msg) {
                                const node = createMessageNode(msg, currentUserId);
                                listEl.appendChild(node);
                                lastMessageId = Math.max(lastMessageId, Number(msg.id || 0));
                            });
                            inputEl.value = "";
                            inputEl.focus();
                            scrollToBottom();
                        } else {
                            throw new Error("invalid-send-response");
                        }
                    } catch (e) {
                        formEl.submit();
                    } finally {
                        sending = false;
                    }
                });

                scrollToBottom();
                setInterval(fetchNewMessages, 2500);
            })();
        </script>

    </body>
</html>