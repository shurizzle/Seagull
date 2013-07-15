defmodule Compiler.MenuItem do

  def compile(id, title, options, data) do
    if id==:_, do: id=Compiler.random_id
    {pre, post}=divide_options options
    pre=[{:parentMenu, Keyword.get(data, :wxparent)}, {:text, binary_to_list(title)}|pre]
    pre=Compiler.fuse_styles pre
    pid=Keyword.get data, :pid
    data=Keyword.delete data, :pid
    my_pid=Keyword.get options, :pid, pid
    wxitem = :wxMenuItem.new pre
    {:wx_ref, wxitem_id, :wxMenuItem, _}=wxitem
    :wxMenu.append Keyword.get(data, :wxparent), wxitem_id, binary_to_list(title)
    data=[type: :menu_item, wxobject: wxitem, id: id, pid: my_pid]++data
    compile_options(data, post)
    [{id, data}]
  end

  defp divide_options(options), do: divide_options options, [], []
  defp divide_options([], pre, post), do: {pre, post}
  defp divide_options([{:react, events}|tail], pre, post), do: divide_options tail, pre, [{:react, events}|post]
  defp divide_options([{:pid, _}|tail], pre, post), do: divide_options tail, pre, post
  
  defp compile_options(_data, []), do: true
  defp compile_options(data, [head|tail]) do
    compile_option data, head
    compile_options data, tail
  end

  defp compile_option(data, {:react, events}), do: react data, events

  defp react(_data, []), do: true
  defp react(data, [event|tail]) do
    if Event.MenuItem.react(data, event) do
      react data, tail
    else
      raise {:uknown_event, event}
    end
  end

end
