defmodule PhoenixChatgptPlugin.Serving.Similarity do
  @moduledoc """
  The similarity embedding model.

  Can be replaced with another open source model from HuggingFace
  or an API-based model such as OpenAI or Cohere.

  Note that even for external API-based models, it might still
  benefit to wrap the model in an Nx.Serving in order to get automatic
  batching. It's more efficient to send overlapping concurrent requests
  to the API at once rather than one at a time. Nx.Serving offers
  this functionality out of the box.
  """
  import Nx.Defn

  @doc """
  Gets a single embedding prediction.
  """
  def predict(text) do
    Nx.Serving.batched_run(__MODULE__, text)    
  end

  @doc """
  Embedding serving implementation.
  """
  def serving(opts \\ []) do
    batch_size = opts[:batch_size] || 1

    {:ok, %{model: model, params: params}} =
      Bumblebee.load_model({:hf, "sentence-transformers/all-MiniLM-L6-v2"})

    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "sentence-transformers/all-MiniLM-L6-v2"})

    {_init_fun, predict_fun} = Axon.build(model)

    scores_fun = fn params, inputs ->
      outputs = predict_fun.(params, inputs)
      mean_pooling(outputs.hidden_state, inputs["attention_mask"])
    end

    Nx.Serving.new(fn defn_options ->
      scores_fun = Nx.Defn.jit(scores_fun, defn_options)
      fn inputs ->
        inputs = maybe_pad(inputs, batch_size)
        scores_fun.(params, inputs)
      end
    end)
    |> Nx.Serving.process_options(batch_size: batch_size)
    |> Nx.Serving.client_preprocessing(fn input ->
      texts = validate_input!(input)

      inputs =
        Bumblebee.apply_tokenizer(tokenizer, texts,
          return_token_type_ids: false
        )

      {Nx.Batch.concatenate([inputs]), :ok}
    end)
    |> Nx.Serving.client_postprocessing(fn scores, _metadata, :ok ->
      Bumblebee.Utils.Nx.batch_to_list(scores)
    end)
  end

  defnp mean_pooling(model_output, attention_mask) do
    input_mask_expanded = Nx.new_axis(attention_mask, -1)

    model_output
    |> Nx.multiply(input_mask_expanded)
    |> Nx.sum(axes: [1])
    |> Nx.divide(Nx.sum(input_mask_expanded, axes: [1]))
  end

  defp maybe_pad(batch, nil), do: batch

  defp maybe_pad(%{size: size}, batch_size) when size > batch_size do
    raise ArgumentError,
          "input batch size (#{size}) exceeds the maximum configured batch size (#{batch_size})"
  end

  defp maybe_pad(%{size: size} = batch, batch_size) do
    Nx.Batch.pad(batch, batch_size - size)
  end

  defp validate_input!(inputs) when is_list(inputs) do
    for input <- inputs do
      if not is_binary(input) do
        raise ArgumentError, "expected input to be binary"
      end
    end

    inputs
  end

  defp validate_input!(input) when is_binary(input) do
    [input]
  end

  defp validate_input!(_input) do
    raise ArgumentError, "expected input to be binary"
  end
end
