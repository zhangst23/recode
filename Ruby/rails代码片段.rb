rails代码片段.rb

1.0  #


<div class="container">
  <% flash.each do |name, msg| %>
	<div class="alert alert<%= name == :notice ? "success" : "error" %>">
		<a class="close" data-dismiss="alert">x</a>
		<%= msg %>
	</div>
  <% end %>
</div>






























































































































































































































































































































































































































































































































































































































