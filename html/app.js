/* =============== helpers =============== */
const $  = id => document.getElementById(id);
const NUI= (cb,data={}) => fetch(`https://${GetParentResourceName()}/${cb}`,{
  method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data)});

/* =============== refs =============== */
const PANEL=$('panel'), JOBT=$('jobTable'),
      MOD=$('modal'),   MT=$('modalTitle'), MB=$('modalBody');
let  modalCB=null;

/* =============== reset =============== */
function reset(){ PANEL.classList.add('hidden'); MOD.classList.add('hidden');
  modalCB=null; document.body.classList.remove('active'); }

/* =============== modal =============== */
function show(title,fields,cb){
  MT.textContent=title; MB.innerHTML='';
  fields.forEach(f=>{
    MB.insertAdjacentHTML('beforeend',`<label>${f.label}</label>
      <input id="${f.name}" type="${f.type||'text'}" value="${f.value??''}"><br>`);
  }); modalCB=cb; MOD.classList.remove('hidden');
}
$('modalOk').onclick   =()=>{ if(modalCB){
  const d={}; MB.querySelectorAll('input').forEach(i=>d[i.id]=i.value); modalCB(d); }
  MOD.classList.add('hidden'); modalCB=null; };
$('modalCancel').onclick =()=>{ MOD.classList.add('hidden'); modalCB=null; };

/* =============== rendu jobs =============== */
function drawJobs(list){
  let h='<thead><tr><th>Job</th><th></th></tr></thead><tbody>';
  list.forEach(j=>{
    h+=`<tr><td>${j.label} (${j.name})</td>
        <td><button onclick="openBoss('${j.name}')">Ouvrir Boss-Menu</button></td></tr>`;
  });
  JOBT.innerHTML=h+'</tbody>';
  PANEL.classList.remove('hidden'); document.body.classList.add('active');
}
window.openBoss=job=>{ NUI('openJobBoss',job); reset(); };

/* =============== création job =============== */
function openCreate(){
  show('Créer un job',[
    {label:'Nom technique',  name:'jname'},
    {label:'Label',          name:'jlabel'},
    {label:'Salaire',        name:'jsal',  type:'number',value:'150'},
    {label:'Grade boss (ID)',name:'jboss', type:'number',value:'4'}
  ],d=>{
    NUI('createJob',{
      name:d.jname,label:d.jlabel,
      salary:parseInt(d.jsal,10)||0,
      bossGrade:parseInt(d.jboss,10)||4
    });
  });
}

/* =============== boutons =============== */
$('btnCreateJob').onclick=openCreate;
$('btnClose').onclick    =()=>{ reset(); NUI('close'); };

/* =============== messages FiveM =============== */
window.addEventListener('message',e=>{
  if(e.data.action==='open')      drawJobs(e.data.jobs);
  else if(e.data.action==='close')reset();
});

/* =============== ESC clavier =============== */
window.addEventListener('keydown',e=>{
  if(e.key==='Escape'){
    if(!MOD.classList.contains('hidden')) MOD.classList.add('hidden');
    else { reset(); NUI('close'); }
  }
});
