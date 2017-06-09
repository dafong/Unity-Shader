using UnityEngine;
using UnityEditor;
using System.Collections;

[ExecuteInEditMode]
public class ComputeDiffuseEnvironmentMap : MonoBehaviour
{
	public Cubemap originalCubeMap; 
	// environment map specified in the shader by the user
	//[System.Serializable] 
	// avoid being deleted by the garbage collector, 
	// and thus leaking
	private Cubemap filteredCubeMap; 
	// the computed diffuse irradience environment map 

	private void Update()
	{
		Cubemap originalTexture = null;
		try
		{
			originalTexture = GetComponent<Renderer>().sharedMaterial.GetTexture(
				"_OriginalCube") as Cubemap;
		}
		catch (System.Exception)
		{
			Debug.LogError("'_OriginalCube' not found on shader. " 
				+ "Are you using the wrong shader?");
			return;
		}

		if (originalTexture == null) 
			// did the user set "none" for the map?
		{
			if (originalCubeMap != null)
			{
				GetComponent<Renderer>().sharedMaterial.SetTexture("_Cube", null);
				originalCubeMap = null;
				filteredCubeMap = null;
				return;
			}
		}
		else if (originalTexture == originalCubeMap 
			&& filteredCubeMap != null 
			&& GetComponent<Renderer>().sharedMaterial.GetTexture("_Cube") == null)
		{
			GetComponent<Renderer>().sharedMaterial.SetTexture("_Cube", 
				filteredCubeMap); // set the computed 
			// diffuse environment map in the shader
		}
		else if (originalTexture != originalCubeMap 
			|| filteredCubeMap  
			!= GetComponent<Renderer>().sharedMaterial.GetTexture("_Cube")) 
		{
			if (EditorUtility.DisplayDialog(
				"Processing of Environment Map",
				"Do you want to process the cube map of face size " 
				+ originalTexture.width + "x" + originalTexture.width 
				+ "? (This will take some time.)", 
				"OK", "Cancel"))
			{
				if (filteredCubeMap 
					!= GetComponent<Renderer>().sharedMaterial.GetTexture("_Cube"))
				{
					if (GetComponent<Renderer>().sharedMaterial.GetTexture("_Cube") 
						!= null)
					{
						DestroyImmediate(
							GetComponent<Renderer>().sharedMaterial.GetTexture(
								"_Cube")); // clean up
					}
				}
				if (filteredCubeMap != null)
				{
					DestroyImmediate(filteredCubeMap); // clean up
				}
				originalCubeMap = originalTexture;
				filteredCubeMap = computeFilteredCubeMap(); 
				//computes the diffuse environment map
				GetComponent<Renderer>().sharedMaterial.SetTexture("_Cube", 
					filteredCubeMap); // set the computed 
				// diffuse environment map in the shader
				return;
			}
			else
			{
				originalCubeMap = null;
				filteredCubeMap = null;
				GetComponent<Renderer>().sharedMaterial.SetTexture("_Cube", null);
				GetComponent<Renderer>().sharedMaterial.SetTexture(
					"_OriginalCube", null);
			}
		}
	}

	// This function computes a diffuse environment map in 
	// "filteredCubemap" of the same dimensions as "originalCubemap"
	// by integrating -- for each texel of "filteredCubemap" -- 
	// the diffuse illumination from all texels of "originalCubemap" 
	// for the surface normal vector corresponding to the direction 
	// of each texel of "filteredCubemap".
	private Cubemap computeFilteredCubeMap()
	{
		Cubemap filteredCubeMap = new Cubemap(originalCubeMap.width, 
			originalCubeMap.format, true);

		int filteredSize = filteredCubeMap.width;
		int originalSize = originalCubeMap.width;

		// Compute all texels of the diffuse environment cube map 
		// by itterating over all of them
		for (int filteredFace = 0; filteredFace < 6; filteredFace++) 
			// the six sides of the cube
		{
			for (int filteredI = 0; filteredI < filteredSize; filteredI++)
			{
				for (int filteredJ = 0; filteredJ < filteredSize; filteredJ++)
				{
					Vector3 filteredDirection = 
						getDirection(filteredFace, 
							filteredI, filteredJ, filteredSize).normalized;
					float totalWeight = 0.0f;
					Vector3 originalDirection;
					Vector3 originalFaceDirection;
					float weight;
					Color filteredColor = new Color(0.0f, 0.0f, 0.0f);

					// sum (i.e. integrate) the diffuse illumination 
					// by all texels in the original environment map
					for (int originalFace = 0; originalFace < 6; originalFace++)
					{
						originalFaceDirection = getDirection(
							originalFace, 1, 1, 3).normalized; 
						//the normal vector of the face

						for (int originalI = 0; originalI < originalSize; originalI++)
						{
							for (int originalJ = 0; originalJ < originalSize; originalJ++)
							{
								originalDirection = getDirection(
									originalFace, originalI, 
									originalJ, originalSize); 
								// direction to the texel 
								// (i.e. light source)
								weight = 1.0f 
									/ originalDirection.sqrMagnitude; 
								// take smaller size of more 
								// distant texels into account
								originalDirection = 
									originalDirection.normalized;
								weight = weight * Vector3.Dot(
									originalFaceDirection, 
									originalDirection); 
								// take tilt of texel compared 
								// to face into account
								weight = weight * Mathf.Max(0.0f, 
									Vector3.Dot(filteredDirection, 
										originalDirection)); 
								// directional filter 
								// for diffuse illumination
								totalWeight = totalWeight + weight; 
								// instead of analytically 
								// normalization, we just normalize 
								// to the potential max illumination
								filteredColor = filteredColor + weight 
									* originalCubeMap.GetPixel(
										(CubemapFace)originalFace, 
										originalI, originalJ); // add the 
								// illumination by this texel 
							}
						}
					}
					filteredCubeMap.SetPixel(
						(CubemapFace)filteredFace, filteredI, 
						filteredJ, filteredColor / totalWeight); 
					// store the diffuse illumination of this texel
				}
			}
		}

		// Avoid seams between cube faces: average edge texels 
		// to the same color on each side of the seam
		int maxI = filteredCubeMap.width - 1;
		for (int i = 0; i < maxI; i++)
		{
			setFaceAverage(ref filteredCubeMap, 
				0, i, 0, 2, maxI, maxI - i);
			setFaceAverage(ref filteredCubeMap, 
				0, 0, i, 4, maxI, i);
			setFaceAverage(ref filteredCubeMap, 
				0, i, maxI, 3, maxI, i);
			setFaceAverage(ref filteredCubeMap, 
				0, maxI, i, 5, 0, i);

			setFaceAverage(ref filteredCubeMap, 
				1, i, 0, 2, 0, i);
			setFaceAverage(ref filteredCubeMap, 
				1, 0, i, 5, maxI, i);
			setFaceAverage(ref filteredCubeMap, 
				1, i, maxI, 3, 0, maxI - i);
			setFaceAverage(ref filteredCubeMap, 
				1, maxI, i, 4, 0, i);

			setFaceAverage(ref filteredCubeMap, 
				2, i, 0, 5, maxI - i, 0);
			setFaceAverage(ref filteredCubeMap, 
				2, i, maxI, 4, i, 0);
			setFaceAverage(ref filteredCubeMap, 
				3, i, 0, 4, i, maxI);
			setFaceAverage(ref filteredCubeMap, 
				3, i, maxI, 5, maxI - i, maxI);
		}

		// Avoid seams between cube faces: 
		// average corner texels to the same color 
		// on all three faces meeting in one corner
		setCornerAverage(ref filteredCubeMap, 
			0, 0, 0, 2, maxI, maxI, 4, maxI, 0);
		setCornerAverage(ref filteredCubeMap, 
			0, maxI, 0, 2, maxI, 0, 5, 0, 0);
		setCornerAverage(ref filteredCubeMap, 
			0, 0, maxI, 3, maxI, 0, 4, maxI, maxI);
		setCornerAverage(ref filteredCubeMap, 
			0, maxI, maxI, 3, maxI, maxI, 5, 0, maxI);
		setCornerAverage(ref filteredCubeMap, 
			1, 0, 0, 2, 0, 0, 5, maxI, 0);
		setCornerAverage(ref filteredCubeMap, 
			1, maxI, 0, 2, 0, maxI, 4, 0, 0);
		setCornerAverage(ref filteredCubeMap, 
			1, 0, maxI, 3, 0, maxI, 5, maxI, maxI);
		setCornerAverage(ref filteredCubeMap, 
			1, maxI, maxI, 3, 0, 0, 4, 0, maxI);

		filteredCubeMap.Apply(); //apply all SetPixel(..) commands

		return filteredCubeMap;
	}

	private void setFaceAverage(ref Cubemap filteredCubeMap, 
		int a, int b, int c, int d, int e, int f)
	{
		Color average = 
			(filteredCubeMap.GetPixel((CubemapFace)a, b, c) 
				+ filteredCubeMap.GetPixel((CubemapFace)d, e, f)) / 2.0f;
		filteredCubeMap.SetPixel((CubemapFace)a, b, c, average);
		filteredCubeMap.SetPixel((CubemapFace)d, e, f, average);
	}

	private void setCornerAverage(ref Cubemap filteredCubeMap, 
		int a, int b, int c, int d, int e, int f, int g, int h, int i)
	{
		Color average = 
			(filteredCubeMap.GetPixel((CubemapFace)a, b, c) 
				+ filteredCubeMap.GetPixel((CubemapFace)d, e, f) 
				+ filteredCubeMap.GetPixel((CubemapFace)g, h, i)) / 3.0f;
		filteredCubeMap.SetPixel((CubemapFace)a, b, c, average);
		filteredCubeMap.SetPixel((CubemapFace)d, e, f, average);
		filteredCubeMap.SetPixel((CubemapFace)g, h, i, average);
	}

	private Vector3 getDirection(int face, int i, int j, int size)
	{
		switch (face)
		{
		case 0:
			return new Vector3(0.5f, 
				-((j + 0.5f) / size - 0.5f), 
				-((i + 0.5f) / size - 0.5f));
		case 1:
			return new Vector3(-0.5f, 
				-((j + 0.5f) / size - 0.5f), 
				((i + 0.5f) / size - 0.5f));
		case 2:
			return new Vector3(((i + 0.5f) / size - 0.5f), 
				0.5f, ((j + 0.5f) / size - 0.5f));
		case 3:
			return new Vector3(((i + 0.5f) / size - 0.5f), 
				-0.5f, -((j + 0.5f) / size - 0.5f));
		case 4:
			return new Vector3(((i + 0.5f) / size - 0.5f),  
				-((j + 0.5f) / size - 0.5f), 0.5f);
		case 5:
			return new Vector3(-((i + 0.5f) / size - 0.5f), 
				-((j + 0.5f) / size - 0.5f), -0.5f);
		default:
			return Vector3.zero;
		}
	}
}