document.addEventListener("turbo:load", function () {
    const chatBox = document.getElementById("chat-box");

    if (chatBox) {
        chatBox.scrollTop = chatBox.scrollHeight;
    }
});