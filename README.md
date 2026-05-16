#  Floriam

A simple iOS app to identify a plant from a picture taken with the camera or from the Photos App. The app uses [Pl@ntNet API](https://my.plantnet.org/doc/api/openapi) to identify the plant or the plant disease in the picture, "The identification engine is based on most advanced deep learning technologies ..."

<p float="left">
  <img src="picture2.png" width="333"  height="444" />
</p>


## Usage

First, tap the **gear icon**, enter your **PlantNet API key** and if available your **Google AI Gemini key** and save. 

Adjust how many images to keep in your **History**, the default is 10.

Secondly, toggle the **Identify/Disease** to identify the **plant** or the **disease** from the picture. Google AI Gemini when available, can provide additional information about the disease.

Then, select the **Camera** or **Photos**.

Multiple photo selections (up to 3) from the **Photos App** can used to identify **one** plant.  

When using the **Camera**, only the one picture is used to identify the plant.

A long press on a picture will bring the **Share** panel.

Tap on the results to get more information.


### References

-   [Pl@ntNet](https://my.plantnet.org/)

-   [Pl@ntNet API](https://my.plantnet.org/doc/api/openapi)

See also

-   [Global Biodiversity Information Facility](https://www.gbif.org/)

-   [GBIF API Reference](https://techdocs.gbif.org/en/openapi/)

### Requirements

-   A valid **PlantNet API key** is required. Create an account at [Pl@ntNet](https://my.plantnet.org/) to obtain one. A free account can be used.

-   Optionally, a **Google Gemini key**, see [Google AI key](https://ai.google.dev/gemini-api/docs/api-key). The AI is used to provide more information about any identified disease.

#### Dependencies

-    [GeminiKitAPI](https://github.com/workingDog/GeminiKitAPI) derived from the original repo [GeminiKit](https://github.com/guitaripod/GeminiKit)
-    [Textual](https://github.com/gonzalezreal/swift-markdown-ui) to display Markdown
