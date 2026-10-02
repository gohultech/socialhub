import consumer from "./consumer"

consumer.subscriptions.create("MessagesChannel", {
  connected() {
    console.log("Connected to MessagesChannel")
  },

  disconnected() {
    console.log("Disconnected")
  },

  received(data) {
    const chatBox = document.getElementById("chat-box")

    if (!chatBox) return

    const currentUserId = Number(chatBox.dataset.currentUserId)

    // Only show the message if the current user is the receiver
    if (Number(data.receiver_id) !== currentUserId) return

    chatBox.innerHTML += `
      <div class="text-start mb-3">
        <div class="d-inline-block">
          <span class="badge bg-secondary p-3">
            ${data.content}
          </span>

          <div class="small text-muted mt-1">
            ${data.created_at}
          </div>
        </div>
      </div>
    `

    chatBox.scrollTop = chatBox.scrollHeight
  }
})