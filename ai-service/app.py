from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Dict, Any

from services.face_service import get_face_embedding
from services.recognition_service import find_best_match
app = FastAPI()


class FaceRequest(BaseModel):
    image_path: str


class RecognitionRequest(BaseModel):
    image_path: str
    students: List[Dict[str, Any]]

@app.get("/")
def home():
    return {
        "message": "AI Service Running"
    }


@app.get("/health")
def health():
    return {
        "status": "success"
    }


@app.post("/enroll-face")
def enroll_face(data: FaceRequest):

    embedding = get_face_embedding(
        data.image_path
    )

    if embedding is None:
        return {
            "success": False,
            "message": "No face detected"
        }

    return {
        "success": True,
        "embedding_length": len(embedding),
        "embedding": embedding
    }


@app.post("/recognize-face")
def recognize_face(data: RecognitionRequest):

    print("Image Path:", data.image_path)
    print("Students Received:", len(data.students))

    embedding = get_face_embedding(
        data.image_path
    )

    if embedding is None:
        return {
            "success": False,
            "message": "No face detected"
        }

    if len(data.students) == 0:
        return {
            "success": False,
            "message": "No students provided"
        }

    student, score = find_best_match(
        embedding,
        data.students
    )

    if student is None:
        return {
            "success": False,
            "message": "No matching student found"
        }

    return {
        "success": True,
        "recognized_student": {
            "id": student.get("_id"),
            "name": student.get("name")
        },
        "confidence": round(score, 4)
    }
