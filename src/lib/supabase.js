// ShareVault backend adapter. Add VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY when ready.
export const supabaseConfig={url:import.meta.env.VITE_SUPABASE_URL||'',anonKey:import.meta.env.VITE_SUPABASE_ANON_KEY||''};
export const backendReady=Boolean(supabaseConfig.url&&supabaseConfig.anonKey);

export async function apiRequest(path,options={}){
  if(!backendReady) throw new Error('Backend is not configured yet. Add Supabase environment variables.');
  const response=await fetch(`${supabaseConfig.url}/rest/v1/${path}`,{
    ...options,
    headers:{apikey:supabaseConfig.anonKey,Authorization:`Bearer ${supabaseConfig.anonKey}`,'Content-Type':'application/json',...(options.headers||{})}
  });
  if(!response.ok) throw new Error(`ShareVault API error ${response.status}`);
  if(response.status===204) return null;
  return response.json();
}
