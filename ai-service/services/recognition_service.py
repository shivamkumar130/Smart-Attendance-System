import numpy as np
from sklearn.metrics.pairwise import cosine_similarity

def find_best_match(target_embedding, students):

    best_score = -1
    best_student = None

    target = np.array(
        target_embedding
    ).reshape(1, -1)

    for student in students:

        if len(student["faceEmbedding"]) == 0:
            continue

        stored = np.array(
            student["faceEmbedding"]
        ).reshape(1, -1)

        score = cosine_similarity(
            target,
            stored
        )[0][0]

        if score > best_score:
            best_score = score
            best_student = student

    return best_student, float(best_score)