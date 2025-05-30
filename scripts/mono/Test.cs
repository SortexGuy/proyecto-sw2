using static Godot.GD;

public class Test
{
	static Test()
	{
		Godot.Node node = new Godot.Node();
		node._Ready();
		Print("Hello"); // Instead of GD.Print("Hello");
	}
}
