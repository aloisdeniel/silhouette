<script>
  var count = state(0);
  var double = derived(() => count * 2);
  
  effect(() {
    print('Count is now: $count');
  });
  
  void increment() {
    count = count + 1;
  }
  
  void decrement() {
    count = count - 1;
  }
</script>

<div>
  <h1>Counter Example</h1>
  <p>Count: {count}</p>
  <p>Double: {double}</p>
  
  <button on:click={increment}>Increment</button>
  <button on:click={decrement}>Decrement</button>
  
  {#if count > 10}
    <p>Count is greater than 10!</p>
  {:else}
    <p>Count is 10 or less</p>
  {/if}
</div>

<style>
  div {
    padding: 20px;
    font-family: Arial, sans-serif;
  }
  
  button {
    margin: 5px;
    padding: 10px 20px;
    cursor: pointer;
  }
</style>
