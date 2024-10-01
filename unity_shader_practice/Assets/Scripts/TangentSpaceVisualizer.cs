using UnityEngine;

public class TangentSpaceVisualizer : MonoBehaviour
{

    public float offset = 0.01f;
    public float scale = 0.1f;

    void OnDrawGizmos()
    {
        MeshFilter filter = GetComponent<MeshFilter>();
        if (filter)
        {
            Mesh mesh = filter.sharedMesh;
            if (mesh)
            {
                ShowTangentSpace(mesh);
            }
        }
    }

    void ShowTangentSpace(Mesh mesh)
    {
        Vector3[] vertices = mesh.vertices;
        Vector3[] normals = mesh.normals;
        for (int i = 0; i < vertices.Length; i++)
        {
            ShowTangentSpace(
                transform.TransformPoint(vertices[i]),
                transform.TransformDirection(normals[i])
            );
        }
    }

    void ShowTangentSpace(Vector3 vertex, Vector3 normal)
    {
        vertex += normal * offset;
        Gizmos.color = Color.green;
        Gizmos.DrawLine(vertex, vertex + normal * scale);
    }
}