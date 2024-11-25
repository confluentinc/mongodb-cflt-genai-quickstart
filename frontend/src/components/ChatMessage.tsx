export interface ChatMessage {
  role: "client" | "server";
  userId: string;
  data: string;
}
