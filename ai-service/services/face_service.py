import cv2
import os
from insightface.app import FaceAnalysis

face_app = FaceAnalysis()
face_app.prepare(ctx_id=0)

def get_face_embedding(image_path):

    print("Path:", image_path)
    print("Exists:", os.path.exists(image_path))

    image = cv2.imread(image_path)

    if image is None:
        print("Failed to load image")
        return None

    print("Image Shape:", image.shape)

    faces = face_app.get(image)

    print("Faces Found:", len(faces))

    if len(faces) == 0:
        print("No faces found")
        return None

    embedding = faces[0].embedding

    return embedding.tolist()