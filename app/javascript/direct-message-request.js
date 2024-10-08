document.addEventListener("turbo:load", () => {
  const directMessageStartButton = document.querySelector(".direct-message-image");
  const directMessageStart = document.querySelector(".direct-message-box");
  const directMessageChoiceBox = document.querySelector(".direct-message-yes-or-no")
  const directMessageCancel = document.querySelector(".direct-message-no");
  const directMessageYesButton = document.querySelector(".direct-message-yes");
  const directMessageText = document.getElementById("direct-message-text");

  if (!directMessageStartButton || !directMessageStart || !directMessageYesButton || !directMessageCancel || !directMessageText) {
    return;
  }

  directMessageStartButton.addEventListener("click", () => {
    directMessageStart.style.display = "block";
  });

  directMessageCancel.addEventListener("click", () => {
    directMessageStart.style.display = "none";
  });

  directMessageYesButton.addEventListener("click", () => {
    const receiverId = directMessageStartButton.dataset.userId;

    fetch("/direct_message_requests", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ direct_message_request: { receiver_id: receiverId } })
    })
    .then(response => {
      if (!response.ok) {
        return response.text().then(text => { throw new Error(text); });
      }
      return response.json();
    })
    .then(data => {
      if (data.success) {
        directMessageText.textContent = "申請中";
        directMessageChoiceBox.style.display = "none";
      } else {
        alert("申請に失敗しました: " + data.errors.join(", "));
      }
    })
    .catch(error => {
      console.error("Error:", error);
      alert("申請に失敗しました。エラー: " + error.message);
    });
  });
});
