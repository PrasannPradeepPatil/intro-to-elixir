defmodule Calculator  do
  #CREATE PROCESS ID
  def start do                                                               #pid = Calculator.start
    spawn(fn -> loop(0) end)
  end
  
  #SEND PROCESS ID ALONG WITH A MESSAGE TO MAILBOX 
  def add(server_pid, value), do: send(server_pid, {:add, value})          #Calculator.add(pid, 1);Calculator.sub(pid, 1);Calculator.mul(pid, 1);Calculator.div(pid, 1);Calculator.view(pid)
  def sub(server_pid, value), do: send(server_pid, {:sub, value})
  def mult(server_pid, value), do: send(server_pid, {:mult, value})
  def div(server_pid, value), do: send(server_pid, {:div, value})
  def view(server_pid) do   #at server end send pid along with message ;at receiverr pattern match message and then send id along with message ; again at sender end pattern match id
    send(server_pid, {:view, self()})
    receive do
      {:response, value} ->value
    end
  end

  #RECEIVE MESSAGE AND PERFORM PATTERM MATCHING BY LOOPING RECURSIVELY 
  defp loop(current_value) do
    new_value =
      receive do
        {:add, value} ->current_value + value
        {:sub, value} ->current_value - value
        {:mult, value} ->current_value * value
        {:div, value} ->current_value / value
        {:view, caller_pid} ->
               send(caller_pid, {:response, current_value})
               current_value
        _ ->IO.puts("Invalid Message")
      end

    loop(new_value)
  end
  



end

