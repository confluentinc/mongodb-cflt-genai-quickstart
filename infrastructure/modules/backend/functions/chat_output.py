from dataclasses import dataclass


@dataclass
class ChatOutputValue:
    session_id: str
    user_id: str
    output: str

    @staticmethod
    def json_schema():
        return """
    {
      "properties": {
        "output": {
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

    def to_dict(self, ctx = None):
        return dict(
            output=self.output,
            userId=self.user_id,
            sessionId=self.session_id
        )

    @staticmethod
    def from_dict(obj, ctx = None):
        if any(obj.get(field) is None for field in ["sessionId", "userId", "output"]):
            raise ValueError("ChatOutputValue is missing required params.")
        return ChatOutputValue(
            session_id=obj.get("sessionId"),
            user_id=obj.get("userId"),
            output=obj.get("output")
        )


@dataclass()
class ChatOutputKey:
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

    @staticmethod
    def to_dict(key, ctx):
        return dict(sessionId=key.session_id)

    @staticmethod
    def from_dict(obj, ctx):
        if obj.get("sessionId") is None:
            raise ValueError("ChatOutputKey is missing required params.")
        return ChatOutputKey(session_id=obj.get("sessionId"))
