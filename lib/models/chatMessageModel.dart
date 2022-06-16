class ChatMessage {
  String messageContent;
  String messageType;
  ChatMessage({required this.messageContent, required this.messageType});
}

List<ChatMessage> messages = [
  ChatMessage(
      messageContent: "Hello, apa yang ingin kamu tanyakan tentang sampah?",
      messageType: "receiver"),
  ChatMessage(messageContent: "apa itu sampah?", messageType: "sender"),
];
