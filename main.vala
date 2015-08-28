using Gtk;

public class DockerGui: Window {

    struct Container {
        string Id;
        string Image;

        public string to_string() {
            return @"$(Id), $(Image)";
        }
    }

    public DockerGui() {
        this.title = "Docker Gui";
        set_default_size(300, 100);
        var view = new TreeView();
        setup_treeview(view);
        add(view);
        this.destroy.connect(Gtk.main_quit);
    }

    private void setup_treeview(TreeView view) {
        var listmodel = new Gtk.ListStore(4, typeof(string), typeof(string), typeof(string), typeof(string));
        view.set_model(listmodel);

        view.insert_column_with_attributes(-1, "ContainerId", new CellRendererText(), "text", 0);
        view.insert_column_with_attributes(-1, "Image", new CellRendererText(), "text", 1);

		get_containers(listmodel);

        view.row_activated.connect(on_row_activated);
        view.get_selection().changed.connect(on_selection);
    }

	private void get_containers(Gtk.ListStore listmodel){

        TreeIter iter;
		var uri = "http://localhost:5555/containers/json";
		var session = new Soup.Session();
		var message = new Soup.Message("GET", uri);
		session.send_message(message);	
		var parser = new Json.Parser();
		parser.load_from_data((string) message.response_body.flatten().data, -1);
		Json.Array jsonContainers = parser.get_root().get_array();

		foreach (Json.Node c in jsonContainers.get_elements()){
			var o = c.get_object();
			string Id = o.get_string_member("Id");
		    string Image = o.get_string_member("Image");
	        // stdout.printf("%s - %s\n", Id, Image);
			listmodel.append(out iter);
			listmodel.set(iter, 0, Id, 1, Image);
		}

	}


    private static Container get_selection(Gtk.TreeModel model, Gtk.TreeIter iter) {
        var c = Container();
        model.get(iter, 0, out c.Id, 1, out c.Image);
        return c;
    }

    private void on_row_activated(Gtk.TreeView treeview , Gtk.TreePath path, Gtk.TreeViewColumn column) {
        Gtk.TreeIter iter;
        if(treeview.model.get_iter(out iter, path)) {
             Container c = get_selection(treeview.model, iter);
			 // stdout.printf(@"GO $(c)\n");
        }
    }

    private void on_selection(Gtk.TreeSelection selection) {
        Gtk.TreeModel model;
        Gtk.TreeIter iter;
        if(selection.get_selected(out model, out iter)) {
            Container c = get_selection(model, iter);
			// stdout.printf(@"WARM $(c)\n");
        }
    }

    public static int main(string[] args) {
        Gtk.init(ref args);

        var dockerGui = new DockerGui();
        dockerGui.show_all();
        Gtk.main();

        return 0;
    }
}
