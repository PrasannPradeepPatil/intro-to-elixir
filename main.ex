#########################################################CONCURRENCY########################################################################################
defmodule Calculator  do
CLIENT SIDE
  #CREATE PROCESS ID
  def start do                                                                ###pid = Calculator.start
    spawn(fn -> loop(0) end)
  end
  
  #SEND PROCESS ID ALONG WITH A MESSAGE TO MAILBOX 
  def add(server_pid, value), do: send(server_pid, {:add, value})             ###Calculator.add(pid, 1);Calculator.sub(pid, 1);Calculator.mul(pid, 1);Calculator.div(pid, 1);Calculator.view(pid)
  def sub(server_pid, value), do: send(server_pid, {:sub, value})
  def mult(server_pid, value), do: send(server_pid, {:mult, value})
  def div(server_pid, value), do: send(server_pid, {:div, value})
  def view(server_pid) do            #at server end send pid along with message ;at receiverr pattern match  
    send(server_pid, {:view, self()})message and then send id along with message again at sender end pattern match id
    receive do
      {:response, value} ->value
    end
  end

SERVER SIDE
  #RECEIVE MESSAGE AND PERFORM PATTERM MATCHING BY LOOPING RECURSIVELY 
  defp loop(current_value) do
    new_value =
      receive do                                                                   ###receive do pattern matches the message in mailbox
        {:add, value} ->current_value + value
        {:sub, value} ->current_value - value
        {:mult, value} ->current_value * value
        {:div, value} ->current_value / value
        {:view, caller_pid} ->
               send(caller_pid, {:response, current_value})
               current_value
        _ ->IO.puts("Invalid Message")
      end
      
 
    after                                                                           ###if pattern not matched timeout after 500 ms
    500 -> IO.puts "Times up"
    loop(new_value)
  end
  

end
end

#########################################################GENSERVER --- https://hexdocs.pm/elixir/GenServer.html########################################################################################
                                                         DIAGRAM -->https://www.youtube.com/watch?v=0tQ8nfKQBL0&list=PLJbE2Yu2zumA-p21bEQB6nsYABAO-HtF2&index=10 0:51

GENSERVER.EX
defmodule Stack do
  use GenServer
  use GenServer, restart: :transient, shutdown: 10_000  -->  list of options which configures the child specification and therefore how it runs under a supervisor. 
                                                            :id - the child specification identifier, defaults to the current module
                                                            :restart - when the child should be restarted, defaults to :permanent
                                                            :shutdown - how to shut down the child, either immediately or by giving it time to shut down
CLIENT SIDE
  #CREATE PROCESS ID
  def start_link(default) when is_list(default) do              ###pid = Stack.start_link()
    GenServer.start_link(__MODULE__, default)                  -->list of args which decide how the genserver starts under supervisro
                                                                  __MODULE__  -->gives name of module
                                                                  :name option --> registers the genserver
                                                                                  an atom - the GenServer is registered locally with the given name using Process.register/2.
                                                                                             EG # Start the server and register it locally with name MyStack
                                                                                                  {:ok, _} = GenServer.start_link(Stack, [:hello], name: MyStack)
                                                                                                   # Now messages can be sent directly to MyStack
                                                                                                   GenServer.call(MyStack, :pop)

                                                                                  {:global, term} - the GenServer is registered globally with the given term using the functions in the :global module.

                                                                                   {:via, module, term} - the GenServer is registered with the given mechanism and name. The :via option expects a module that exports register_name/2, unregister_name/1,
                                                                                                          whereis_name/1 and send/2. One such example is the :global module which uses these functions for keeping the list of names of processes and their associated 
                                                                                                          PIDs that are available globally for a network of Elixir nodes. Elixir also ships with a local, decentralized and scalable registry called Registry for locally
                                                                                                          storing names that are generated dynamically.

  #SEND PROCESS ID ALONG WITH A MESSAGE TO MAILBOX 
  def push(pid, element) do                                     ###Stack.push(pid,2) ;Stack.pop(pid) 
    GenServer.cast(pid, {:push, element})
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

SERVER SIDE
  #RECEIVE MESSAGE AND PERFORM PATTERM MATCHING 
  @impl true                                                   ### init/1 is a callback to start_link() 
  def init(stack) do
    {:ok, stack}
  end
  
  @impl true
  def handle_call(:pop, _from, [head | tail]) do               ###call/2 is a synchronous fn that requires a reply and and pettern matches to call on client side(pop in our case)
    {:reply, head, tail}
  end

  @impl true
  def handle_cast({:push, element}, state) do                  ###cast/3 is a asynchronous fn that does requires a reply and and pettern matches to cast on client side(push in our case)
    {:noreply, [element | state]}
  end


  @impl true
  def handle_info(:work, state) do                            ###handle_info handles "regular" messages sent by functions such as Kernel.send/2, Process.send_after/4 
    # Do the desired work here                                   OR  handling monitor DOWN messages sent by Process.monitor/1 
                                                                 OR  perform periodic work, with the help of Process.send_after/4: 
    # Reschedule once more
    schedule_work()
    {:noreply, state}
  end
  
  defp schedule_work do
    # In 2 hours
    Process.send_after(self(), :work, 2 * 60 * 60 * 1000)
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

#########################################################GENTAGE########################################################################################
1.C:\User\Dell\desktop\ElixirBasic >mix new projectname --sup  create --> create basic project;--sup will create in lib--foldername--application.ex
2.You add producer.ex , consumer.ex , producer_consumer.ex   and in mix.exs add genstage in dependencies   defp deps do[{:gen_stage, "~> 0.11"},] 
3.C:\User\Dell\desktop\ElixirBasic >mix do deps.get , compile --> compile added dependencies
  
PRODUCER.EX
defmodule Gencounter.Producer do
	use GenStage

	def start_link(init \\ 0) do
		GenStage.start_link(__MODULE__, init, name: __MODULE__)
	end

	def init(counter), do: {:producer, counter}

	def handle_demand(demand, state) do
		events = Enum.to_list(state..state + demand - 1)
		{:noreply, events, (state+demand)}
	end
end


PRODUCER-CONSUMER.EX
defmodule Gencounter.ProducerConsumer do
	use GenStage

	require Integer

	def start_link do
		GenStage.start_link(__MODULE__, :state, name: __MODULE__)
	end

	def init(state) do
		{:producer_consumer, state, subscribe_to: [Gencounter.Producer]}
	end

	def handle_events(events, _from, state) do
		numbers =
			events 
			|> Enum.filter(&Integer.is_even/1)

		{:noreply, numbers, state}
	end
end


CONSUMER.EX
defmodule Gencounter.Consumer do
	use GenStage

	def start_link do 
		GenStage.start_link(__MODULE__, :state)
	end

	def init(state) do
		{:consumer, state, subscribe_to: [Gencounter.ProducerConsumer]}
	end

	def handle_events(events, _from, state) do
		for event <- events do
			IO.inspect {self(), event, state}
		end

		{:noreply, [], state}
	end
end


