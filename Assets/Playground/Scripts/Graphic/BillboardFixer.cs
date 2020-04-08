using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshRenderer))]
public class BillboardFixer : MonoBehaviour
{
    MeshRenderer mesh;

    void BillboardFix(Mesh mesh)
    {
        var vertices = mesh.vertices;
        var uvs = new List<Vector3>(mesh.vertexCount);
        for (var i = 0; i < mesh.vertexCount; ++i)
        {
            var uv = vertices[i];
            uvs.Add(uv);
        }
        mesh.SetUVs(1, uvs);
    }
}
