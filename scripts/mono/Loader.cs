using Godot;
using System;

public partial class Loader : Node3D
{
    public override void _Ready()
    {
        HttpRequest httpRequest = new HttpRequest();
        this.AddChild(httpRequest);
        httpRequest.RequestCompleted += (result, responseCode, headers, body) => _HttpRequestCompleted(result, responseCode, headers, body);
        httpRequest.DownloadFile = "./models/pico.glb";

        // Perform the HTTP request. The URL below returns a PNG image as of writing.
        Error error = httpRequest.Request("http://localhost:3000/static/pico.glb");
        if (error != Error.Ok)
        {
            GD.PushError("An error occurred in the HTTP request: (error code: ).");
        }
    }

    // Called when the HTTP request is completed.
    public void _HttpRequestCompleted(long result, long responseCode, string[] headers, byte[] body)
    {
        if (result != (long)HttpRequest.Result.Success)
        {
            GD.PushError("File couldn't be downloaded.");
        }
        GD.PushWarning(GD.VarToStr(headers));

        // Load an existing glTF scene.
        // GLTFState is used by GLTFDocument to store the loaded scene's state.
        // GLTFDocument is the class that handles actually loading glTF data into a Godot node tree,
        // which means it supports glTF features such as lights and cameras.
        GltfDocument glDoc = new GltfDocument();
        GltfState glState = new GltfState();
        Error error = glDoc.AppendFromFile("./models/pico.glb", glState);
        if (error == Error.Ok)
        {
            Node glRootNode = glDoc.GenerateScene(glState);
            this.AddChild(glRootNode);
        }
        else
        {
            GD.PushError("Couldn't load glTF scene");
        }
    }
}
