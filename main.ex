#########################################################CONCURRENCY########################################################################################
defmodule Calculator  do
CLIENT SIDE
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

SERVER SIDE
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
      
    # IF NO PATTERN MATCHED ISSUE A TIMEOUTLIKE  500 MILLISECONDS
    after
    500 -> IO.puts "Times up"
    loop(new_value)
  end
  

end
end

#########################################################GENSERVER########################################################################################
GENSERVER.EX
defmodule Stack do
  use GenServer
  use GenServer, restart: :transient, shutdown: 10_000  --> accepts a list of options which configures the child specification and therefore how it runs under a supervisor. 
                                                            :id - the child specification identifier, defaults to the current module
                                                            :restart - when the child should be restarted, defaults to :permanent
                                                            :shutdown - how to shut down the child, either immediately or by giving it time to shut down
CLIENT SIDE
  #CREATE PROCESS ID
  def start_link(default) when is_list(default) do             #pid = Stack.start_link()
    GenServer.start_link(__MODULE__, default) #__MODULE__ gives name of module
  end

  #SEND PROCESS ID ALONG WITH A MESSAGE TO MAILBOX 
  def push(pid, element) do                                   #Stack.push(pid,2) ;Stack.pop(pid) 
    GenServer.cast(pid, {:push, element})
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

SERVER SIDE
  #7 POSSIBLE CALLBACK ; INIT/1 IS REQUIRED
  @impl true
  def init(stack) do
    {:ok, stack}
  end
  
  #RECEIVE MESSAGE AND PERFORM PATTERM MATCHING 
  @impl true
  def handle_call(:pop, _from, [head | tail]) do # requires a reply
    {:reply, head, tail}
  end

  @impl true
  def handle_cast({:push, element}, state) do # does not require a reply
    {:noreply, [element | state]}
  end
end

SUPERVISOR.EX
defmodule StackSupervisor do
  use Supervisor

  #CREATE SUPERVISOR
  def start_link(default) when is_list(default) do      
     children =  Stack # The same as {Stack, []}
    Supervisor.start_link(children, strategy: :one_for_all) #__MODULE__ gives name of module
  end

 




