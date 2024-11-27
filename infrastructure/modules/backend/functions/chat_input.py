from dataclasses import dataclass


@dataclass
class ChatInputValue:
    created_at: int
    input: str
    history: str
    message_id: str
    session_id: str
    user_id: str

    @staticmethod
    def json_schema():
        return """
    {
      "properties": {
        "createdAt": {
          "connect.index": 4,
          "oneOf": [
            {
              "type": "null"
            },
            {
              "connect.type": "int64",
              "title": "org.apache.kafka.connect.data.Timestamp",
              "type": "number"
            }
          ]
        },
        "input": {
          "connect.index": 3,
          "oneOf": [
            {
              "type": "null"
            },
            {
              "type": "string"
            }
          ]
        },
        "history": {
          "connect.index": 5,
          "oneOf": [
            {
              "type": "null"
            },
            {
              "type": "string"
            }
          ]
        },
        "messageId": {
          "connect.index": 2,
          "oneOf": [
            {
              "type": "null"
            },
            {
              "type": "string"
            }
          ]
        },
        "userId": {
          "connect.index": 1,
          "oneOf": [
            {
              "type": "null"
            },
            {
              "type": "string"
            }
          ]
        },
        "sessionId": {
          "connect.index": 0,
          "oneOf": [
            {
              "type": "null"
            },
            {
              "type": "string"
            }
          ]
        }
      },
      "title": "Record",
      "type": "object"
    }
    """

    @staticmethod
    def to_dict(value, ctx=None):
        return dict(
            createdAt=value.created_at,
            input=value.input,
            history=value.history,
            messageId=value.message_id,
            sessionId=value.session_id,
            userId=value.user_id
        )

    @staticmethod
    def from_dict(obj, ctx=None):
        if any(obj.get(field) is None for field in ["createdAt", "input", "messageId", "sessionId", "userId"]):
            raise ValueError("ChatInputValue is missing required params.")

        conversation = obj.get("input")
        humanIndex = conversation.rfind("Human:", 0)
        humanRequest = conversation[humanIndex:]
        history = conversation[:humanIndex]

        return ChatInputValue(
            created_at=obj.get("createdAt"),
            input=humanRequest,
            history=history,
            message_id=obj.get("messageId"),
            session_id=obj.get("sessionId"),
            user_id=obj.get("userId")
        )


@dataclass
class ChatInputKey:
    session_id: str

    @staticmethod
    def json_schema():
        return """
        {
          "properties": {
            "sessionId": {
              "connect.index": 0,
              "type": "string"
            }
          },
          "required": [
            "sessionId"
          ],
          "title": "Record",
          "type": "object"
        }
        """

    def to_dict(key, ctx=None):
        return dict(sessionId=key.session_id)

    @staticmethod
    def from_dict(obj, ctx=None):
        if obj.get("sessionId") is None:
            raise ValueError("ChatInputKey is missing required params.")
        return ChatInputKey(session_id=obj.get("sessionId"))
