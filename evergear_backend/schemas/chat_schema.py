from pydantic import BaseModel
from typing import List

# Matches the exact map keys in chats_list_screen.dart
class ChatSummaryResponse(BaseModel):
    id: int
    otherUser: str
    product: str
    lastMessage: str
    time: str
    unread: int

# Matches the exact map keys in chat_screen.dart
class MessageResponse(BaseModel):
    text: str
    isMe: bool

class SendMessageRequest(BaseModel):
    text: str