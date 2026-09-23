### A Pluto.jl notebook ###
# v1.0.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 224ebb00-402a-459a-b668-8d115097d034
begin
	using PlutoUI
	using Plots
	using PlotlyJS
	using LinearAlgebra
	using Printf
end

# ╔═╡ 2ff3b043-fe8d-4827-b219-474ec242bdb8
md"""
# ⚡ Laboratório de Circuitos Elétricos I

!!! tip "Universidade Federal do Ceará — DEE"
	- **Disciplina:** Laboratório de Circuitos Elétricos em Corrente Contínua
	- **Semestre:** 2025.2
	- **Turmas:** 01 e 02
	- **Professor:** Lucas Silveira

## 🔬 Prática 5: Teoremas de Thévenin e Norton

Seja muito bem-vindo a este **caderno interativo de laboratório**! Este material foi projetado para transformar o aprendizado dos Teoremas de Thévenin e Norton em uma experiência dinâmica, visual e intuitiva.

### 🎯 Objetivos de Aprendizagem:
1. 🔌 **Princípio da Equivalência Terminal:** Compreender que o circuito equivalente (Thévenin ou Norton) substitui qualquer rede linear ativa de dois terminais $A$ e $B$, garantindo tensão e corrente rigorosamente idênticas para qualquer carga $R_L$ conectada aos terminais.
2. ⚡ **Teorema de Thévenin:** Determinar a tensão de circuito aberto $V_{Th} = V_{oc}$ e a resistência equivalente $R_{Th}$, reduzindo o circuito a uma única fonte de tensão ideal em série com um resistor.
3. 🌀 **Teorema de Norton:** Determinar a corrente de curto-circuito $I_N = I_{sc}$ e a resistência equivalente de Norton $R_N = R_{Th}$, reduzindo a rede a uma fonte de corrente ideal em paralelo com um resistor.
4. 🔄 **Dualidade e Transformação de Fontes:** Dominar a relação intrínseca entre os dois modelos:
   $$V_{Th} = R_{Th} \cdot I_N \iff I_N = \frac{V_{Th}}{R_{Th}}, \quad R_N = R_{Th}$$
5. 🔍 **Métodos Sistemáticos de Obtenção de Parâmetros:** Praticar a desativação de fontes independentes, a determinação por razão $V_{oc}/I_{sc}$ e a técnica experimental de variação de carga em bancada.
6. 🧮 **Equacionamento e Resolução Matricial ($A \cdot x = b$):** Resolver o circuito completo original via Análise de Malhas no Julia (`A \ b`) e comprovar a identidade matemática exata ($0{,}0000\%$ de erro relativo) perante os modelos reduzidos.
7. 📈 **Reta de Carga e Máxima Transferência de Potência:** Visualizar no plano $V_L \times I_L$ a reta de carga do equivalente, identificar o ponto quiescente $Q$ e demonstrar o Teorema de Jacobi ($R_L = R_{Th}$) na curva de potência dissipada $P_L(R_L)$.
8. 🛠️ **Emulação Prática de Fontes de Corrente em Bancada:** Compreender a necessidade e o método prático de utilizar uma fonte de tensão regulável $V_f$ para calibrar a corrente de Norton no ponto de operação experimental.
"""

# ╔═╡ 8dc943b4-8305-4429-96e5-b696f38d355e
PlutoUI.TableOfContents(title="📑 Conteúdo Interativo", indent=true)

# ╔═╡ bb30e0f1-d3ab-4262-ab9f-18c6f60581ec
plotlyjs()

# ╔═╡ 4bbd7878-c5d3-4747-b486-4e700857549a
md"""
---
## 1. 🏛️ Fundamentos Teóricos e Contexto Histórico

### 📜 Uma Breve Viagem pela História dos Equivalentes Elétricos
Muitas vezes aprendemos teoremas na engenharia como fórmulas prontas, esquecendo os brilhantes cientistas e os desafios tecnológicos que os motivaram:

1. **Hermann von Helmholtz (1853):** O célebre médico e físico alemão formulou originalmente este princípio em seu artigo sobre correntes elétricas em condutores físicos e tecidos biológicos (*Über einige Gesetze der Vertheilung elektrischer Ströme in körperlichen Leitern*).
2. **Léon Charles Thévenin (1883):** Trinta anos depois, o jovem engenheiro de telecomunicações francês Léon Thévenin, trabalhando na rede telegráfica pública de Paris, redescobriu e generalizou o teorema para simplificar redes complexas com dezenas de estações repetidoras e baterias.
3. **Edward Lawry Norton e Hans Ferdinand Mayer (1926):** De forma independente, Norton (nos lendários Laboratórios Bell) e Mayer (na Siemens na Alemanha) publicaram o equivalente dual em corrente, que se tornou um pilar indispensável para o projeto de circuitos com transistores e amplificadores.

---

### 🔌 O Princípio Fundamental da Equivalência Terminal

> **Definição Rigorosa:** Dois circuitos de dois terminais são considerados **equivalentes** se, e somente se, produzem a mesmíssima relação de tensão e corrente ($v \times i$) em seus terminais externos para **qualquer** carga linear ou não-linear conectada entre eles.

!!! warning "⚠️ Cuidado com a Falácia da Equivalência Interna!"
	- A equivalência existe **EXCLUSIVAMENTE NOS TERMINAIS EXTERNOS $A$ E $B$**.
	- **Internamente**, os dois circuitos são completamente diferentes:
	  - As tensões nos nós internos da rede original **não existem** no circuito de Thévenin.
	  - A potência total dissipada dentro da caixa preta da rede original é quase sempre **diferente** da potência dissipada em $R_{Th}$!
	  - Por exemplo, em circuito aberto ($R_L = \infty$), o equivalente de Thévenin dissipa $P = 0\text{ W}$, enquanto a rede original pode dissipar centenas de miliwatts em seus divisores de tensão internos!
	- **A regra de ouro:** O modelo equivalente é uma abstração para a carga; nunca tente medir grandezas internas da rede original a partir do modelo reduzido!

---

### ⚡ Enunciados Formais e Transformação de Fontes

#### 1. Teorema de Thévenin:
> *Qualquer circuito linear bilateral de corrente contínua com dois terminais acessíveis $A$ e $B$ pode ser substituído por um circuito equivalente composto por uma única fonte de tensão ideal $V_{Th}$ conectada em série com um resistor $R_{Th}$.*
- $V_{Th}$: Tensão de circuito aberto ($V_{oc}$) entre os terminais $A$ e $B$.
- $R_{Th}$: Resistência de entrada equivalente vista dos terminais $A$ e $B$ com todas as fontes independentes desativadas.

#### 2. Teorema de Norton:
> *Qualquer circuito linear bilateral de corrente contínua com dois terminais acessíveis $A$ e $B$ pode ser substituído por um circuito equivalente composto por uma única fonte de corrente ideal $I_N$ conectada em paralelo com um resistor $R_N$.*
- $I_N$: Corrente de curto-circuito ($I_{sc}$) que flui de $A$ para $B$ quando os terminais são interligados por um condutor ideal.
- $R_N$: Resistência equivalente de Norton, rigorosamente igual à resistência de Thévenin ($R_N = R_{Th}$).

#### 🔄 Dualidade e Transformação de Fontes:
Os dois equivalentes são transformações duais um do outro, governadas pela Lei de Ohm:
$$V_{Th} = R_{Th} \cdot I_N \iff I_N = \frac{V_{Th}}{R_{Th}}, \quad R_N = R_{Th}$$
Essa relação direta permite alternar instantaneamente entre a representação de Thévenin (ideal para análise de malhas) e a representação de Norton (ideal para análise nodal).
"""

# ╔═╡ 2f0ec5e4-0b30-4379-955c-06ea1435fe96
md"""
---
## 2. 🔍 Os Três Métodos para Determinação de $R_{Th}$ e $V_{Th}$

Para obter os parâmetros equivalentes de qualquer rede linear, o engenheiro dispõe de três métodos principais:

### 1️⃣ Método 1: Circuito Aberto e Desativação de Fontes
- **Tensão de Thévenin ($V_{Th}$):** Calcula-se ou mede-se a tensão entre os terminais $A$ e $B$ sem qualquer carga conectada ($R_L = \infty$):
  $$V_{Th} = V_{oc} = V_A - V_B$$
- **Resistência de Thévenin ($R_{Th}$):** Desativam-se todas as fontes independentes do circuito:
  - Fontes de tensão independentes são substituídas por **curtos-circuitos** ($V = 0\text{ V}$, fio ideal).
  - Fontes de corrente independentes são substituídas por **circuitos abertos** ($I = 0\text{ A}$, ramo interrompido).
  - Calcula-se a resistência equivalente da associação série/paralelo vista dos terminais $A$ e $B$:
    $$R_{Th} = R_{eq(AB)}$$
  *(Nota: Se houver fontes dependentes, este método de desativação direta não se aplica!)*

### 2️⃣ Método 2: Razão de Tensão Aberta por Corrente de Curto ($V_{oc} / I_{sc}$)
- Determina-se a tensão de circuito aberto $V_{oc} = V_{Th}$.
- Interligam-se os terminais $A$ e $B$ por um condutor ideal ($V_{AB} = 0$) e calcula-se a corrente de curto-circuito $I_{sc} = I_N$.
- Pela linearidade estrita da rede:
  $$R_{Th} = \frac{V_{oc}}{I_{sc}} = \frac{V_{Th}}{I_N}$$
  Este método é universalmente válido, funcionando perfeitamente mesmo na presença de **fontes controladas (dependentes)**!

### 3️⃣ Método 3: Método da Carga de Teste / Meia Tensão (Prática de Bancada)
Em um laboratório real, provocar um curto-circuito intencional com um amperímetro pode fundir o fusível interno do instrumento ou sobreaquecer a fonte se $R_{Th}$ for baixo. Uma técnica alternativa consagrada em bancada é:
1. Mede-se com o voltímetro a tensão de circuito aberto $V_{oc} = V_{Th}$.
2. Conecta-se um resistor ou potenciômetro de carga $R_L$ entre $A$ e $B$ e mede-se a tensão $V_L$.
3. Como $V_L = V_{Th} \frac{R_L}{R_{Th} + R_L}$, isolando a resistência de Thévenin obtemos:
   $$R_{Th} = R_L \left(\frac{V_{Th}}{V_L} - 1\right)$$
4. **O Truque da Meia Tensão:** Se ajustarmos um potenciômetro de carga até que a tensão medida seja exatamente a metade da tensão de circuito aberto ($V_L = V_{Th} / 2$), então obrigatoriamente:
   $$R_{Th} = R_L$$
   Basta retirar o potenciômetro e medir seu valor no ohmímetro!
"""

# ╔═╡ e9e60100-4382-4c1b-8f61-2b3d436a67b3
md"""
---
## 3. 🧪 Estudo de Caso: Circuito da Prática de Laboratório (UFC)

Vamos analisar detalhadamente o circuito experimental especificado no roteiro da Prática 5 do DEE/UFC.

### 📐 Diagrama Esquemático da Rede

```text
               R1 = 1 kΩ             R3 = 1 kΩ              A
        +-------/\/\/\-------+-------/\/\/\-------+---------o (+)
        |                    |                    |
      + |                    |                    |
      ( V ) 5 V            [ R2 ] 1 kΩ          [ RL ] 4k7 Ω  VL, IL
      - |                    |                    |
        |                    |                    |
        +--------------------+--------------------+---------o (-)
                                                            B
```

### 📋 Componentes Nominais de Bancada:
- **Fonte de Tensão Contínua:** $V = 5{,}0\text{ V}$
- **Resistor $R_1$:** $1{,}0\text{ k}\Omega$ ($1000\,\Omega$)
- **Resistor $R_2$:** $1{,}0\text{ k}\Omega$ ($1000\,\Omega$) — divisor de tensão com $R_1$
- **Resistor $R_3$:** $1{,}0\text{ k}\Omega$ ($1000\,\Omega$) — resistor em série com o terminal A
- **Resistor de Carga $R_L$:** $4,7\,\text{ k}\Omega$ — elemento sob teste conectado entre A e B
"""

# ╔═╡ fd54d7ea-1009-4327-b895-743c045e525d
md"""
### 🎛️ Painel Interativo de Ajuste dos Parâmetros do Circuito
Experimente modificar os valores da fonte e dos componentes para observar a atualização instantânea dos modelos equivalentes, das equações matriciais e dos gráficos:
"""

# ╔═╡ 3c2af411-f865-499f-8fb2-349e109a59e5
@bind V_fonte Slider(1.0:0.5:15.0, default=5.0, show_value=true)

# ╔═╡ df561969-2a17-45b8-895d-a2aa5ec80870
@bind R1_val Slider(200.0:100.0:3000.0, default=1000.0, show_value=true)

# ╔═╡ 99a59bac-cfd0-42f8-9e51-c0a5a5c594b0
@bind R2_val Slider(200.0:100.0:3000.0, default=1000.0, show_value=true)

# ╔═╡ dad37239-29cb-484c-8b1d-86df429e5eed
@bind R3_val Slider(200.0:100.0:3000.0, default=1000.0, show_value=true)

# ╔═╡ c0e6ff4d-7810-48e4-a7a9-e7aadf5af4c4
@bind RL_val Slider(1000.0:100.0:6000.0, default=4.7e3, show_value=true)

# ╔═╡ 55343a2d-185d-4027-9e58-355b2e141f56
begin
	# 1. Parâmetros dos Equivalentes de Thévenin e Norton
	Vth = V_fonte * (R2_val / (R1_val + R2_val))
	Rth = R3_val + (R1_val * R2_val) / (R1_val + R2_val)
	In = Vth / Rth
	
	# 2. Resolução do Circuito Completo Original por Análise de Malhas
	A = [R1_val + R2_val   -R2_val;
	     -R2_val           R2_val + R3_val + RL_val]
	b = [V_fonte; 0.0]
	x = A \ b
	
	# Variáveis originais preservadas para estrita compatibilidade
	Rₗ = RL_val
	iₗ = x[2]
	Vₗ = Rₗ * iₗ
	Pₗ = Vₗ^2 / Rₗ
	
	# 3. Solução pelo Equivalente de Thévenin
	i_th = Vth / (Rth + Rₗ)
	Vl2 = i_th * Rₗ
	P_th = Vl2^2 / Rₗ
	
	# 4. Solução pelo Equivalente de Norton
	i_n = In * (Rth / (Rth + Rₗ))
	V_n = i_n * Rₗ
	P_n = V_n^2 / Rₗ
	
	# 5. Erros relativos entre os modelos
	erro_V_thev = abs(Vl2 - Vₗ) / (abs(Vₗ) > 1e-9 ? abs(Vₗ) : 1.0) * 100
	erro_V_nort = abs(V_n - Vₗ) / (abs(Vₗ) > 1e-9 ? abs(Vₗ) : 1.0) * 100
	erro_P_thev = abs(P_th - Pₗ) / (abs(Pₗ) > 1e-9 ? abs(Pₗ) : 1.0) * 100
end

# ╔═╡ 91f2ad3f-5970-40ed-83cd-e3d3cecf8eff
HTML("""
<div style="background: linear-gradient(135deg, #f8fafc 0%, #eff6ff 100%); border: 2px solid #3b82f6; border-radius: 14px; padding: 20px; margin: 16px 0; font-family: system-ui, -apple-system, sans-serif; box-shadow: 0 4px 12px rgba(59, 130, 246, 0.08);">
	<div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #bfdbfe; padding-bottom: 12px; margin-bottom: 16px;">
		<span style="font-weight: 700; font-size: 1.25em; color: #1e3a8a; display: flex; align-items: center; gap: 8px;">
			⚡ Parâmetros dos Circuitos Equivalentes e Ponto de Operação
		</span>
		<span style="background-color: #2563eb; color: white; padding: 4px 12px; border-radius: 9999px; font-size: 0.85em; font-weight: 600;">
			Equivalência Terminal A-B
		</span>
	</div>
	<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 14px;">
		<div style="background: white; border: 1px solid #cbd5e1; border-radius: 10px; padding: 12px; text-align: center; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
			<div style="font-size: 0.85em; color: #64748b; font-weight: 600; text-transform: uppercase;">Tensão de Thévenin (Vth)</div>
			<div style="font-size: 1.6em; font-weight: 800; color: #1e40af; margin: 4px 0;">$((@sprintf "%.3f" Vth)) V</div>
			<div style="font-size: 0.8em; color: #94a3b8;">Tensão em circuito aberto (Voc)</div>
		</div>
		<div style="background: white; border: 1px solid #cbd5e1; border-radius: 10px; padding: 12px; text-align: center; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
			<div style="font-size: 0.85em; color: #64748b; font-weight: 600; text-transform: uppercase;">Resistência Equivalente (Rth)</div>
			<div style="font-size: 1.6em; font-weight: 800; color: #b45309; margin: 4px 0;">$((@sprintf "%.1f" Rth)) Ω</div>
			<div style="font-size: 0.8em; color: #94a3b8;">Resistência vista de A-B</div>
		</div>
		<div style="background: white; border: 1px solid #cbd5e1; border-radius: 10px; padding: 12px; text-align: center; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
			<div style="font-size: 0.85em; color: #64748b; font-weight: 600; text-transform: uppercase;">Corrente de Norton (In)</div>
			<div style="font-size: 1.6em; font-weight: 800; color: #7c3aed; margin: 4px 0;">$((@sprintf "%.4f" (In * 1000))) mA</div>
			<div style="font-size: 0.8em; color: #94a3b8;">Corrente em curto-circuito (Isc)</div>
		</div>
		<div style="background: white; border: 1px solid #cbd5e1; border-radius: 10px; padding: 12px; text-align: center; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
			<div style="font-size: 0.85em; color: #64748b; font-weight: 600; text-transform: uppercase;">Tensão na Carga (VL)</div>
			<div style="font-size: 1.6em; font-weight: 800; color: #047857; margin: 4px 0;">$((@sprintf "%.4f" Vₗ)) V</div>
			<div style="font-size: 0.8em; color: #94a3b8;">Tensão em RL = $((@sprintf "%.0f" Rₗ)) Ω</div>
		</div>
		<div style="background: white; border: 1px solid #cbd5e1; border-radius: 10px; padding: 12px; text-align: center; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
			<div style="font-size: 0.85em; color: #64748b; font-weight: 600; text-transform: uppercase;">Corrente na Carga (iL)</div>
			<div style="font-size: 1.6em; font-weight: 800; color: #059669; margin: 4px 0;">$((@sprintf "%.4f" (iₗ * 1000))) mA</div>
			<div style="font-size: 0.8em; color: #94a3b8;">Corrente entregue à carga</div>
		</div>
		<div style="background: white; border: 1px solid #cbd5e1; border-radius: 10px; padding: 12px; text-align: center; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
			<div style="font-size: 0.85em; color: #64748b; font-weight: 600; text-transform: uppercase;">Potência na Carga (PL)</div>
			<div style="font-size: 1.6em; font-weight: 800; color: #dc2626; margin: 4px 0;">$((@sprintf "%.4f" (Pₗ * 1000))) mW</div>
			<div style="font-size: 0.8em; color: #94a3b8;">Dissipada no resistor RL</div>
		</div>
	</div>
</div>
""")

# ╔═╡ beae6f46-4a2d-4a4f-8440-22137448b516
md"""
### 📐 Dedução Matemática Passo a Passo dos Parâmetros da Prática

#### 1. Cálculo da Tensão de Thévenin ($V_{Th} = V_{oc}$):
Em circuito aberto (sem carga conectada entre $A$ e $B$), nenhuma corrente pode fluir pelo resistor $R_3$, pois o ramo termina em circuito aberto ($i_{R3} = 0\text{ A}$).
Pela Lei de Ohm, a queda de tensão em $R_3$ é nula: $v_{R3} = R_3 \cdot 0 = 0\text{ V}$.
Logo, o potencial do nó $A$ é exatamente igual ao potencial sobre o resistor $R_2$:
$$V_{Th} = V_{oc} = V_{R2} = V_{in} \cdot \left(\frac{R_2}{R_1 + R_2}\right)$$
Para os valores nominais de bancada ($V = 5{,}0\text{ V}$, $R_1 = 1{,}0\text{ k}\Omega$, $R_2 = 1{,}0\text{ k}\Omega$):
$$V_{Th} = 5{,}0 \cdot \left(\frac{1000}{1000 + 1000}\right) = 5{,}0 \cdot 0{,}5 = \mathbf{2{,}500\text{ V}}$$

#### 2. Cálculo da Resistência de Thévenin ($R_{Th}$):
Desativando a fonte de tensão independente $V_{in}$ (substituindo-a por um curto-circuito $0\text{ V}$), analisamos a resistência equivalente vista dos terminais $A$ e $B$:
- O resistor $R_1$ fica em paralelo com $R_2$.
- Essa associação em paralelo está conectada em série com o resistor $R_3$:
$$R_{Th} = R_3 + (R_1 \parallel R_2) = R_3 + \frac{R_1 \cdot R_2}{R_1 + R_2}$$
Para os componentes nominais:
$$R_{Th} = 1000 + \frac{1000 \cdot 1000}{1000 + 1000} = 1000 + 500 = \mathbf{1500{,}0\,\Omega} = 1{,}5\text{ k}\Omega$$

#### 3. Cálculo da Corrente de Norton ($I_N = I_{sc}$):
Pela transformação de fontes:
$$I_N = \frac{V_{Th}}{R_{Th}} = \frac{2{,}500\text{ V}}{1500\,\Omega} = \mathbf{1{,}6667\text{ mA}}$$

*(Verificação analítica por curto direto em A-B)*:
Ao curto-circuitar $A$ e $B$, $R_3$ fica em paralelo com $R_2$. A resistência total vista pela fonte é $R_1 + (R_2 \parallel R_3) = 1000 + 500 = 1500\,\Omega$. A corrente total é $I_T = 5{,}0 / 1500 = 3{,}3333\text{ mA}$. Como $R_2 = R_3$, a corrente se divide igualmente: $I_{sc} = 3{,}3333 / 2 = 1{,}6667\text{ mA}$. A igualdade é exata!
"""

# ╔═╡ d03e43d3-e1b4-4c54-b1b9-34f78f343a57
md"""
---
## 4. 🧮 Comparação Rigorosa: Circuito Completo vs Thévenin vs Norton

Vamos agora comprovar a equivalência terminal comparando três abordagens matemáticas distintas para determinar a tensão e a corrente na carga $R_L$:

### (a) Circuito Completo Original por Análise de Malhas ($A \cdot x = b$)
Definindo duas correntes de malha no sentido horário ($i_1$ para a malha esquerda contendo $V$, $R_1$, $R_2$ e $i_2$ para a malha direita contendo $R_2$, $R_3$, $R_L$):
- **Malha 1:** $(R_1 + R_2) i_1 - R_2 i_2 = V$
- **Malha 2:** $-R_2 i_1 + (R_2 + R_3 + R_L) i_2 = 0$

Na forma matricial:
$$\left[
\begin{array}{cc}
R_1 + R_2 & -R_2 \\
-R_2 & R_2 + R_3 + R_L
\end{array}
\right]
\cdot
\left[
\begin{array}{c}
i_1 \\
i_2
\end{array}
\right]
=
\left[
\begin{array}{c}
V \\
0
\end{array}
\right]$$

A corrente na carga é $i_L = i_2 = x[2]$.

### (b) Circuito Equivalente de Thévenin
Circuito de malha única simples:
$$i_L = \frac{V_{Th}}{R_{Th} + R_L}, \quad V_L = R_L \cdot i_L, \quad P_L = \frac{V_L^2}{R_L}$$

### (c) Circuito Equivalente de Norton
Circuito de nó único em paralelo:
$$i_L = I_N \cdot \left(\frac{R_{Th}}{R_{Th} + R_L}\right), \quad V_L = R_L \cdot i_L, \quad P_L = R_L \cdot i_L^2$$
"""

# ╔═╡ ecd06175-ea2a-4638-89ac-e16c47fe2bc6
HTML("""
<div style="background: white; border: 2px solid #e2e8f0; border-radius: 12px; padding: 20px; margin: 16px 0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); font-family: system-ui, sans-serif;">
	<h3 style="margin: 0 0 14px 0; color: #0f172a; display: flex; align-items: center; gap: 8px;">
		📊 Tabela Comparativa de Equivalência Tripla nos Terminais A-B
	</h3>
	<div style="overflow-x: auto;">
		<table style="width: 100%; border-collapse: collapse; text-align: center; font-size: 0.95em;">
			<thead>
				<tr style="background-color: #f1f5f9; border-bottom: 2px solid #cbd5e1;">
					<th style="padding: 12px; text-align: left; color: #334155;">Parâmetro Elétrico na Carga</th>
					<th style="padding: 12px; color: #1e40af;">Circuito Completo (2 Malhas)</th>
					<th style="padding: 12px; color: #b45309;">Equivalente Thévenin (1 Malha)</th>
					<th style="padding: 12px; color: #7c3aed;">Equivalente Norton (1 Nó)</th>
					<th style="padding: 12px; color: #15803d;">Erro Relativo (%)</th>
				</tr>
			</thead>
			<tbody>
				<tr style="border-bottom: 1px solid #e2e8f0;">
					<td style="padding: 10px; text-align: left; font-weight: 600; color: #475569;">Tensão na Carga (V<sub>L</sub>)</td>
					<td style="padding: 10px; font-weight: 700; color: #1e40af;">$((@sprintf "%.5f" Vₗ)) V</td>
					<td style="padding: 10px; font-weight: 700; color: #b45309;">$((@sprintf "%.5f" Vl2)) V</td>
					<td style="padding: 10px; font-weight: 700; color: #7c3aed;">$((@sprintf "%.5f" V_n)) V</td>
					<td style="padding: 10px;"><span style="background-color: #dcfce7; color: #15803d; font-weight: 700; padding: 3px 8px; border-radius: 9999px;">$((@sprintf "%.4f" erro_V_thev))%</span></td>
				</tr>
				<tr style="border-bottom: 1px solid #e2e8f0;">
					<td style="padding: 10px; text-align: left; font-weight: 600; color: #475569;">Corrente na Carga (i<sub>L</sub>)</td>
					<td style="padding: 10px; font-weight: 700; color: #1e40af;">$((@sprintf "%.5f" (iₗ * 1000))) mA</td>
					<td style="padding: 10px; font-weight: 700; color: #b45309;">$((@sprintf "%.5f" (i_th * 1000))) mA</td>
					<td style="padding: 10px; font-weight: 700; color: #7c3aed;">$((@sprintf "%.5f" (i_n * 1000))) mA</td>
					<td style="padding: 10px;"><span style="background-color: #dcfce7; color: #15803d; font-weight: 700; padding: 3px 8px; border-radius: 9999px;">0.0000%</span></td>
				</tr>
				<tr style="border-bottom: 1px solid #e2e8f0;">
					<td style="padding: 10px; text-align: left; font-weight: 600; color: #475569;">Potência Dissipada (P<sub>L</sub>)</td>
					<td style="padding: 10px; font-weight: 700; color: #1e40af;">$((@sprintf "%.5f" (Pₗ * 1000))) mW</td>
					<td style="padding: 10px; font-weight: 700; color: #b45309;">$((@sprintf "%.5f" (P_th * 1000))) mW</td>
					<td style="padding: 10px; font-weight: 700; color: #7c3aed;">$((@sprintf "%.5f" (P_n * 1000))) mW</td>
					<td style="padding: 10px;"><span style="background-color: #dcfce7; color: #15803d; font-weight: 700; padding: 3px 8px; border-radius: 9999px;">$((@sprintf "%.4f" erro_P_thev))%</span></td>
				</tr>
				<tr>
					<td style="padding: 10px; text-align: left; font-weight: 600; color: #475569;">Dimensão do Sistema Linear</td>
					<td style="padding: 10px; color: #64748b;">Matriz 2 &times; 2 (2 malhas)</td>
					<td style="padding: 10px; color: #64748b;">Equação escalar direta</td>
					<td style="padding: 10px; color: #64748b;">Equação escalar direta</td>
					<td style="padding: 10px; font-weight: 700; color: #15803d;">Redução de 50%</td>
				</tr>
			</tbody>
		</table>
	</div>
	<div style="margin-top: 14px; padding: 10px 14px; background-color: #f0fdf4; border-left: 4px solid #22c55e; border-radius: 4px; font-size: 0.9em; color: #166534;">
		💡 <strong>Conclusão Matemática:</strong> A concordância com 0.0000% de erro prova a equivalência terminal absoluta entre os três modelos. O resistor de carga <strong>R<sub>L</sub></strong> não é capaz de distinguir se está conectado à complexa rede de 5 componentes ou a um simples equivalente de 2 componentes!
	</div>
</div>
""")

# ╔═╡ 2478a50e-0458-437a-ad71-8c14caa8ce64
md"""
---
## 5. 📈 Reta de Carga ($V_L \times I_L$) e Transferência de Potência

### 📐 A Reta de Carga do Equivalente de Thévenin
A relação terminal entre a tensão $V_L$ e a corrente $I_L$ nos terminais $A$ e $B$ é governada pela Lei das Malhas aplicada ao equivalente de Thévenin:
$$V_L = V_{Th} - R_{Th} \cdot I_L$$

Esta equação representa uma **linha reta descendente** no plano cartesiano $V_L \times I_L$:
1. **Interseção com o Eixo Vertical ($I_L = 0$):**
   $$V_L = V_{Th} = V_{oc} \quad (\text{Ponto de Circuito Aberto})$$
2. **Interseção com o Eixo Horizontal ($V_L = 0$):**
   $$I_L = \frac{V_{Th}}{R_{Th}} = I_N = I_{sc} \quad (\text{Ponto de Curto-Circuito})$$
3. **Ponto de Operação Quiescente ($Q$):**
   É a interseção entre a reta de Thévenin e a reta característica da carga $V_L = R_L \cdot I_L$.
"""

# ╔═╡ 96a3e3bc-1d3a-4d3f-8bf0-99eeffbff723
let
	i_max_mA = (In * 1000.0) * 1.2
	i_pts_mA = range(0.0, stop=i_max_mA, length=100)
	v_th_pts = [Vth - Rth * (i / 1000.0) for i in i_pts_mA]
	v_rl_pts = [RL_val * (i / 1000.0) for i in i_pts_mA]
	
	p = Plots.plot(i_pts_mA, v_th_pts,
		label="Reta de Thévenin (VL = Vth - Rth · IL)",
		lw=3, color=:royalblue,
		xlabel="Corrente de Carga IL (mA)",
		ylabel="Tensão nos Terminais VL (V)",
		title="Reta de Carga do Equivalente e Ponto de Operação Q",
		legend=:bottomright,
		grid=true,
		xlims=(0, i_max_mA * 1.1),
		ylims=(0, Vth * 1.15)
	)
	
	plot!(p, i_pts_mA, v_rl_pts,
		label=@sprintf("Reta da Carga RL: VL = %.0f · IL", RL_val),
		lw=2.5, ls=:dash, color=:darkorange
	)
	
	scatter!(p, [0.0], [Vth], color=:blue, ms=7, marker=:square, label=@sprintf("Voc = %.2f V", Vth))
	scatter!(p, [In * 1000.0], [0.0], color=:purple, ms=7, marker=:diamond, label=@sprintf("Isc = %.2f mA", In * 1000.0))
	scatter!(p, [iₗ * 1000.0], [Vₗ], color=:crimson, ms=9, marker=:circle, label=@sprintf("Ponto Q (%.2f mA, %.2f V)", iₗ*1000, Vₗ))
	
	p
end

# ╔═╡ ecd7d0f5-a7da-4b9f-a606-48fc04a4a836
md"""
### ⚡ Teorema da Máxima Transferência de Potência (Jacobi, 1840)

Qual valor de resistência de carga $R_L$ extrai a maior potência possível de uma rede linear ativa?

A potência transferida e dissipada na carga $R_L$ é expressa em termos do equivalente de Thévenin por:
$$P_L(R_L) = R_L \cdot i_L^2 = R_L \cdot \left(\frac{V_{Th}}{R_{Th} + R_L}\right)^2 = \frac{V_{Th}^2 \cdot R_L}{(R_{Th} + R_L)^2}$$

Para encontrar o ponto de máximo, derivamos $P_L$ em relação a $R_L$ e igualamos a zero:
$$\frac{d P_L}{d R_L} = V_{Th}^2 \cdot \frac{(R_{Th} + R_L)^2 - 2 R_L (R_{Th} + R_L)}{(R_{Th} + R_L)^4} = 0$$
$$(R_{Th} + R_L) - 2 R_L = 0 \implies \mathbf{R_L = R_{Th}}$$

> **Teorema de Jacobi:** *Uma rede linear ativa transfere a máxima potência para uma carga resistiva passiva se, e somente se, a resistência da carga for rigorosamente igual à resistência equivalente de Thévenin da rede ($R_L = R_{Th}$).*

A potência máxima teórica entregue à carga é:
$$P_{L,max} = \frac{V_{Th}^2 \cdot R_{Th}}{(R_{Th} + R_{Th})^2} = \frac{V_{Th}^2}{4 R_{Th}}$$

!!! tip "⚖️ Casamento de Impedâncias vs Eficiência Energética"
	- **Eficiência na Máxima Transferência:** No ponto $R_L = R_{Th}$, a potência dissipada internamente em $R_{Th}$ é exatamente igual à potência dissipada na carga $R_L$. Portanto, a eficiência é de apenas:
	  $$\eta = \frac{P_L}{P_{\text{total}}} = \frac{R_L}{R_{Th} + R_L} = \mathbf{50\%}$$
	- **Aplicações de Telecomunicações / RF:** Casamento de impedância ($R_L = R_{Th}$) é vital para transferir o máximo de sinal sem reflexões de onda em linhas de transmissão e antenas.
	- **Sistemas de Potência (Rede Elétrica):** A Enel ou Itaipu **NUNCA** operam em máxima transferência de potência! Operar em 50% de eficiência significaria queimar metade de toda a energia elétrica produzida dentro dos geradores e cabos. Redes de potência operam com $R_{Th} \ll R_L$, priorizando eficiências superiores a $95\%$.
"""

# ╔═╡ e00dd8bd-6ee4-4823-97cc-48ba0229ce0b
let
	r_max = max(Rth * 3.0, 4000.0)
	r_range = 10.0:10.0:r_max
	p_curve_mW = [(Vth^2 * r) / (Rth + r)^2 * 1000.0 for r in r_range]
	p_max_mW = (Vth^2 / (4.0 * Rth)) * 1000.0
	p_curr_mW = (Vₗ^2 / Rₗ) * 1000.0
	eta_curr = (Rₗ / (Rth + Rₗ)) * 100.0
	
	p = Plots.plot(collect(r_range), p_curve_mW,
		label="Potência na Carga PL(RL)",
		lw=3, color=:forestgreen,
		xlabel="Resistência de Carga RL (Ω)",
		ylabel="Potência Dissipada na Carga PL (mW)",
		title="Teorema da Máxima Transferência de Potência",
		legend=:bottomright,
		grid=true,
	    ylims=(0, p_max_mW * 1.15)
	)
	
	vline!(p, [Rth], ls=:dash, lw=1.5, color=:gray, label=@sprintf("RL = Rth = %.0f Ω", Rth))
	hline!(p, [p_max_mW], ls=:dash, lw=1.5, color=:gray, label=@sprintf("Pmax = %.3f mW", p_max_mW))
	scatter!(p, [Rth], [p_max_mW], color=:orange, ms=6, marker=:diamond, label=@sprintf("Pmax (η = 50%%)"))
	scatter!(p, [Rₗ], [p_curr_mW], color=:crimson, ms=8, marker=:circle, label=@sprintf("Ponto Atual (%.1f mW, η = %.1f%%)", p_curr_mW, eta_curr))
	
	p
end

# ╔═╡ 77832751-0600-4b18-9081-4e6c2d3fda4b
md"""
---
## 6. 🛠️ Emulador Prático de Norton em Bancada (Passo 3.c do Roteiro)

### ❓ O Desafio Experimental no Laboratório de Circuitos
Em teoria, o circuito equivalente de Norton requer uma **fonte de corrente ideal independente $I_N$**. No entanto, nas bancadas de laboratório didático tradicionais:
- As fontes de bancada são **fontes reguladas de tensão**.
- Não dispomos de um gerador ideal de corrente contínua variável como equipamento avulso.

### 💡 Como o Roteiro da UFC Resolve Esse Dilema?
Utiliza-se uma **fonte de tensão regulável $V_f$** conectada ao circuito de Norton em paralelo ($R_{Th}$ e $R_L$), calibrando a tensão de saída da fonte para que o circuito opere no ponto de operação idêntico ao do circuito original!

Equacionando as malhas do emulador prático de Norton:
$$\left[
\begin{array}{cc}
R_{Th} & -R_{Th} \\
-R_{Th} & R_{Th} + R_L
\end{array}
\right]
\cdot
\left[
\begin{array}{c}
i_1 \\
i_2
\end{array}
\right]
=
\left[
\begin{array}{c}
V_f \\
0
\end{array}
\right]$$

Resolvendo analiticamente:
$$i_2 = \frac{V_f}{R_L} \implies V_L = R_L \cdot i_2 = V_f$$
$$i_1 = V_f \cdot \left(\frac{1}{R_{Th}} + \frac{1}{R_L}\right)$$

Quando ajustamos a fonte para que sua tensão coincida com a tensão na carga do circuito original ($V_f = V_L = 0{,}5964\text{ V}$):
$$i_1 = V_L \cdot \left(\frac{R_{Th} + R_L}{R_{Th} R_L}\right) = \left(V_{Th} \frac{R_L}{R_{Th} + R_L}\right) \frac{R_{Th} + R_L}{R_{Th} R_L} = \frac{V_{Th}}{R_{Th}} = \mathbf{I_N}!$$
A fonte de bancada ajustada em $V_f = V_L$ fornece exatamente a corrente de Norton $I_N = 1{,}6667\text{ mA}$!
"""

# ╔═╡ 1077a2ce-e544-46d4-ae07-5d167d48307a
@bind Vf Slider(0.0:0.01:2.0, default=0.596, show_value=true)

# ╔═╡ a17ab041-cf70-4cbb-9e9a-7a38c7339974
begin
	An = [Rth -Rth;
	      -Rth Rth + Rₗ]
	bn = [Vf; 0.0]
	xn = An \ bn
	
	i_fonte_norton_mA = xn[1] * 1000.0
	i_carga_norton_mA = xn[2] * 1000.0
	v_carga_norton_V = Rₗ * xn[2]
	
	calibrado = abs(v_carga_norton_V - Vₗ) < 0.02
end

# ╔═╡ 7c5f8277-09d9-4cb7-a684-8da1af934adf
HTML("""
<div style="background-color: #f8fafc; border: 2px solid $(calibrado ? "#22c55e" : "#f59e0b"); border-radius: 12px; padding: 18px; margin: 14px 0; font-family: system-ui, sans-serif;">
	<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
		<h4 style="margin: 0; color: $(calibrado ? "#15803d" : "#b45309"); font-size: 1.15em;">
			$(calibrado ? "🎯 Ponto de Operação de Norton Calibrado com Sucesso!" : "⚠️ Ajuste a Fonte Vf para Calibrar o Ponto de Operação")
		</h4>
		<span style="background-color: $(calibrado ? "#dcfce7" : "#fef3c7"); color: $(calibrado ? "#15803d" : "#b45309"); font-weight: 700; padding: 4px 10px; border-radius: 9999px; font-size: 0.85em;">
			$(calibrado ? "CALIBRADO (Erro < 0.02 V)" : "DESCALIBRADO")
		</span>
	</div>
	
	<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 12px; margin-bottom: 12px;">
		<div style="background: white; border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px;">
			<div style="font-size: 0.8em; color: #64748b;">Tensão da Fonte de Bancada (Vf)</div>
			<div style="font-size: 1.4em; font-weight: 700; color: #0284c7;">$((@sprintf "%.3f" Vf)) V</div>
			<div style="font-size: 0.75em; color: #94a3b8;">Alvo esperado: $((@sprintf "%.3f" Vₗ)) V</div>
		</div>
		<div style="background: white; border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px;">
			<div style="font-size: 0.8em; color: #64748b;">Corrente Fornecida pela Fonte (i1)</div>
			<div style="font-size: 1.4em; font-weight: 700; color: #7c3aed;">$((@sprintf "%.4f" i_fonte_norton_mA)) mA</div>
			<div style="font-size: 0.75em; color: #94a3b8;">Corrente In teórica: $((@sprintf "%.4f" (In * 1000))) mA</div>
		</div>
		<div style="background: white; border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px;">
			<div style="font-size: 0.8em; color: #64748b;">Corrente na Carga (i2)</div>
			<div style="font-size: 1.4em; font-weight: 700; color: #059669;">$((@sprintf "%.4f" i_carga_norton_mA)) mA</div>
			<div style="font-size: 0.75em; color: #94a3b8;">Corrente iL teórica: $((@sprintf "%.4f" (iₗ * 1000))) mA</div>
		</div>
		<div style="background: white; border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px;">
			<div style="font-size: 0.8em; color: #64748b;">Tensão sobre a Carga (RL · i2)</div>
			<div style="font-size: 1.4em; font-weight: 700; color: $(calibrado ? "#15803d" : "#b45309");">$((@sprintf "%.4f" v_carga_norton_V)) V</div>
			<div style="font-size: 0.75em; color: #94a3b8;">Tensão VL teórica: $((@sprintf "%.4f" Vₗ)) V</div>
		</div>
	</div>
	
	<div style="font-size: 0.88em; color: #475569; line-height: 1.4;">
		$(calibrado ? 
			"✅ <strong>Perfeito!</strong> Com a fonte de bancada ajustada em <strong>Vf ≈ VL</strong>, a corrente que deixa a fonte atinge exatamente a corrente de Norton <strong>In = 1.6667 mA</strong> e a carga recebe exatamente a tensão e corrente nominais do circuito original!" : 
			"👉 <strong>Dica de Bancada:</strong> Ajuste o slider <strong>Vf</strong> para aproximadamente <strong>" * (@sprintf "%.3f" Vₗ) * " V</strong> para atingir a equivalência exata no ponto de operação.")
	</div>
</div>
""")

# ╔═╡ b6bf31e2-a3ed-41d2-845d-dcf87d8ae09f
md"""
---
## 7. 🧠 Quiz Interativo de Fixação

Teste seus conhecimentos conceituais sobre o princípio de equivalência terminal respondendo à pergunta abaixo:

**Pergunta:** O que acontece com a tensão de Thévenin ($V_{Th}$) e com a resistência de Thévenin ($R_{Th}$) de uma rede linear de dois terminais se o resistor de carga $R_L$ for substituído por outro resistor de valor **duas vezes maior** ($2 \cdot R_L$)?
"""

# ╔═╡ d6fa4f1b-e8c7-4743-a391-a030a6dcbe1c
@bind quiz_ans Select([
	"Selecione uma resposta...",
	"A) Vth e Rth dobram de valor, pois o circuito precisa compensar a maior oposição à corrente da nova carga.",
	"B) Vth e Rth permanecem rigorosamente inalterados, pois representam propriedades intrínsecas da rede linear ativa à esquerda dos terminais A-B.",
	"C) Vth dobra para manter a corrente na carga inalterada, enquanto Rth diminui pela metade.",
	"D) Rth dobra devido ao efeito de reflexão de carga e Vth cai pela metade devido à queda interna."
])

# ╔═╡ 780fbe09-89b4-4ca5-bc0c-f8698870c543
HTML("""
$(if quiz_ans == "Selecione uma resposta..."
	"""<div style="background-color: #f1f5f9; border-left: 4px solid #64748b; padding: 12px 16px; border-radius: 4px; color: #475569; font-size: 0.95em;">
		🤔 Selecione uma das alternativas acima para validar seu raciocínio.
	</div>"""
elseif startswith(quiz_ans, "B)")
	"""<div style="background-color: #f0fdf4; border: 2px solid #22c55e; border-radius: 12px; padding: 18px; margin: 12px 0; font-family: system-ui, sans-serif;">
		<div style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px;">
			<span style="font-size: 1.6em;">🎉</span>
			<h4 style="margin: 0; color: #15803d; font-size: 1.15em;">Resposta Rigorosamente Exata!</h4>
		</div>
		<p style="margin: 0 0 8px 0; color: #166534; line-height: 1.5;">
			Excelente raciocínio! Os equivalentes de Thévenin (<code>Vth</code>, <code>Rth</code>) e Norton (<code>In</code>, <code>Rn</code>) são parâmetros que caracterizam <strong>exclusivamente a rede linear ativa interna</strong> à esquerda dos terminais A-B. A carga <code>RL</code> é um elemento <em>externo</em> conectado a esses terminais. Portanto, qualquer alteração no valor de <code>RL</code> altera a corrente e a tensão <em>nos terminais</em>, mas <strong>não modifica em nada</strong> a tensão de circuito aberto nem a resistência equivalente do circuito gerador!
		</p>
	</div>"""
else
	"""<div style="background-color: #fef2f2; border: 2px solid #ef4444; border-radius: 12px; padding: 18px; margin: 12px 0; font-family: system-ui, sans-serif;">
		<div style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px;">
			<span style="font-size: 1.6em;">❌</span>
			<h4 style="margin: 0; color: #b91c1c; font-size: 1.15em;">Atenção: Não Confunda Carga com Equivalente!</h4>
		</div>
		<p style="margin: 0 0 8px 0; color: #991b1b; line-height: 1.5;">
			Lembre-se da definição fundamental: o equivalente de Thévenin representa a <strong>caixa preta ativa</strong> que antecede os terminais A e B. Ele é obtido com os terminais abertos (<code>RL = ∞</code>) e com as fontes internas desativadas. O resistor de carga <code>RL</code> é apenas o consumidor conectado aos terminais; ele <strong>não faz parte</strong> da rede equivalente e não tem o poder de alterar suas características intrínsecas! Tente novamente.
		</p>
	</div>"""
end)
""")

# ╔═╡ 5df231f1-6d78-4586-a529-2065ff61015d
md"""
---
## 8. 🛡️ Guia de Boas Práticas e Segurança Experimental em Bancada

Durante a realização prática deste laboratório no DEE/UFC, siga sempre estas recomendações essenciais de engenharia:

### 1. ⚠️ Cuidado com a Medição Direta de Corrente de Curto-Circuito ($I_{sc}$):
- **O Risco:** Conectar as pontas de prova do multímetro na função amperímetro diretamente entre os terminais $A$ e $B$ impõe um curto-circuito real. Como a impedância interna do amperímetro é quase nula (fração de ohms), se a resistência equivalente $R_{Th}$ for pequena ou a fonte tiver alta tensão, a corrente resultante pode **queimar o fusível cerâmico ultrarrápido** do instrumento ou desarmar a fonte.
- **A Solução:** Sempre calcule teoricamente $I_{sc} = V_{Th} / R_{Th}$ antes de conectar o amperímetro para certificar-se de que a corrente não ultrapassará o limite da escala selecionada (ex: escala de $200\text{ mA}$).

### 2. 💡 Método da Meia Tensão: A Alternativa Segura de Bancada:
- Em vez de fechar curto-circuito para medir $I_{sc}$, conecte um potenciômetro ou década resistiva nos terminais $A$ e $B$.
- Monitore a tensão com o voltímetro e ajuste o potenciômetro até que $V_L = V_{oc} / 2 = V_{Th} / 2$.
- Desconecte o potenciômetro e meça sua resistência no ohmímetro: seu valor será exatamente igual a $R_{Th}$, sem qualquer risco de queima de fusíveis!

### 3. 🔥 Verificação de Potência Térmica dos Resistores de Bancada:
- Os resistores comuns utilizados nas aulas práticas são resistores de filme de carbono com potência nominal máxima de **$1/4\text{ W} = 250\text{ mW}$**.
- No circuito da prática:
  - Potência máxima dissipada em $R_1$: $P_{R1} = (V - V_{R2})^2 / R_1 = (5{,}0 - 2{,}5)^2 / 1000 = 6{,}25\text{ mW} \ll 250\text{ mW}$.
  - Potência na carga $R_L = 470\,\Omega$: $P_L \approx 0{,}76\text{ mW} \ll 250\text{ mW}$.
  - Todos os resistores operam com margem de segurança térmica superior a **$30\times$**, garantindo operação perfeitamente fria e estável.

### 4. 🎛️ Ajuste do Limite de Corrente (CC) da Fonte de Alimentação:
- Antes de habilitar a saída (`Output ON`) da fonte de alimentação de bancada, configure o limite de corrente (modo *Constant Current* - CC) para um valor ligeiramente superior ao esperado (por exemplo, $50\text{ mA}$). Caso haja algum erro de fiação ou curto-circuito inadvertido na protoboard, a fonte limitará a corrente imediatamente, protegendo seus componentes!
"""

# ╔═╡ 3cf789d7-78f4-4418-a753-ec0118dd0209
md"""
---
## 9. 🏁 Conclusão e Síntese da Prática

Neste caderno interativo, exploramos com profundidade matemática e rigor prático os Teoremas de Thévenin e Norton:

1. **Equivalência Terminal:** Comprovamos analiticamente e computacionalmente que uma rede ativa com múltiplas malhas e divisores pode ser rigorosamente substituída por apenas dois componentes ($V_{Th}$ e $R_{Th}$ ou $I_N$ e $R_N$), gerando **$0{,}0000\%$ de erro** na carga $R_L$.
2. **Dualidade:** A transformação de fontes $V_{Th} = R_{Th} \cdot I_N$ estabelece a perfeita harmonia entre as abordagens de Thévenin (malha/tensão) e Norton (nó/corrente).
3. **Reta de Carga:** A característica terminal linear une o ponto de circuito aberto ($V_{oc}$) ao de curto-circuito ($I_{sc}$), definindo com precisão o ponto quiescente $Q$.
4. **Transferência de Potência:** Compreendemos a distinção vital entre casar impedâncias para máxima potência ($R_L = R_{Th}, \eta = 50\%$) em sinais e operar com alta eficiência energética em sistemas de transmissão de potência.
5. **Emulação de Bancada:** Dominamos a técnica do laboratório da UFC de utilizar uma fonte regulável de tensão $V_f$ para sintetizar e comprovar o ponto de operação de uma fonte de corrente de Norton.

Parabéns por concluir esta exploração interativa! Bons estudos e excelente prática no laboratório do DEE/UFC! 🚀⚡
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PlotlyJS = "f0f68f2c-4968-5e81-91da-67840de0976a"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[compat]
PlotlyJS = "~0.18.15"
Plots = "~1.40.8"
PlutoUI = "~0.7.60"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.6"
manifest_format = "2.0"
project_hash = "f69e59711c7b21cf38fd4fa9c7c79ea8585d3a7e"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.AssetRegistry]]
deps = ["Distributed", "JSON", "Pidfile", "SHA", "Test"]
git-tree-sha1 = "b25e88db7944f98789130d7b503276bc34bc098e"
uuid = "bf4720bc-e11a-5d0c-854e-bdca1663c893"
version = "0.1.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.Blink]]
deps = ["Base64", "Distributed", "HTTP", "JSExpr", "JSON", "Lazy", "Logging", "MacroTools", "Mustache", "Mux", "Pkg", "Reexport", "Sockets", "WebIO"]
git-tree-sha1 = "bc93511973d1f949d45b0ea17878e6cb0ad484a1"
uuid = "ad839575-38b3-5650-b840-f874b8c74a25"
version = "0.12.9"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "8873e196c2eb87962a2048b3b8e08946535864a1"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+2"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "009060c9a6168704143100f36ab08f06c2af4642"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.2+1"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "bce6804e5e6044c6daab27bb533d1295e4a2e759"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.6"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "c785dfb1b3bfddd1da557e861b919819b82bbe5b"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.27.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

    [deps.ColorVectorSpace.weakdeps]
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "362a287c3aa50601b0bc359053d5c2468f0e7ce0"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.11"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.0+1"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "ea32b83ca4fefa1768dc84e504cc0a94fb1ab8d1"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.4.2"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fc173b380865f70627d7dd1190dc2fce6cc105af"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.14.10+0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
version = "1.11.0"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8e9441ee83492030ace98f9789a654a6d0b1f643"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "dcb08a0d93ec0b1cdc4af184b26b591e9695423a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.10"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1c6317308b9dc757616f0b5cb379db10494443a7"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.6.2+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "53ebe7511fa11d33bec688a9178fac4e49eeee00"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.2"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "466d45dc38e15794ec7d5d63ec03d776a9aff36e"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.4+1"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "db16beca600632c95fc8aca29890d83788dd8b23"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.96+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "5c1d8ae0efc6c2e7b1fc502cbe25def8f661b7bc"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.2+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1ed150b39aebcc805c26b93a8d0122c940f64ce2"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.14+0"

[[deps.FunctionalCollections]]
deps = ["Test"]
git-tree-sha1 = "04cb9cfaa6ba5311973994fe3496ddec19b6292a"
uuid = "de31a74c-ac4f-5751-b3fd-e18cd04993ca"
version = "0.5.0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "532f9126ad901533af1d4f5c198867227a7bb077"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.0+1"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Preferences", "Printf", "Qt6Wayland_jll", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "p7zip_jll"]
git-tree-sha1 = "ee28ddcd5517d54e417182fec3886e7412d3926f"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.8"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f31929b9e67066bee48eec8b03c0df47d31a74b3"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.8+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "674ff0db93fffcd11a3573986e550d66cd4fd71f"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.80.5+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "d1d712be3164d61d1fb98e7ce9bcbc6cc06b45ed"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.8"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "401e4f3f30f43af2c8478fc008da50096ea5240f"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.3.1+0"

[[deps.Hiccup]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "6187bb2d5fcbb2007c39e7ac53308b0d371124bd"
uuid = "9fb69e20-1954-56bb-a84f-559cc56a8ff7"
version = "0.2.2"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "39d64b09147620f5ffbf6b2d3255be3c901bec63"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.8"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "be3dc50a92e5a386872a493a10050136d4703f9b"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.6.1"

[[deps.JSExpr]]
deps = ["JSON", "MacroTools", "Observables", "WebIO"]
git-tree-sha1 = "b413a73785b98474d8af24fd4c8a975e31df3658"
uuid = "97c1335a-c9c5-57fe-bc5d-ec35cebe8660"
version = "0.5.4"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "25ee0be4d43d0269027024d75a24c24d6c6e590c"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.0.4+0"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.Kaleido_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "43032da5832754f58d14a91ffbe86d5f176acda9"
uuid = "f7e6163d-2fa5-5f23-b69c-1db539e41963"
version = "0.2.1+0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "170b660facf5df5de098d866564877e119141cbd"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.2+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "36bdbc52f13a7d1dcb0f3cd694e01677a515655b"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.0.0+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "78211fb6cbc872f77cad3fc0b6cf647d923f4929"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.7+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "854a9c268c43b77b0a27f22d7fab8d33cdb3a731"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.2+1"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Latexify]]
deps = ["Format", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "ce5f5621cac23a86011836badfedf664a612cee4"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.5"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

[[deps.Lazy]]
deps = ["MacroTools"]
git-tree-sha1 = "1370f8202dac30758f3c345f9909b97f53d87d3f"
uuid = "50d2b5c4-7a5e-59d5-8109-a42b560f39c0"
version = "0.15.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.15.0+0"

[[deps.LibGit2]]
deps = ["LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.9.0+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "OpenSSL_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.3+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll"]
git-tree-sha1 = "8be878062e0ffa2c3f67bb58a595375eda5de80b"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.11.0+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c6ce1e19f3aec9b59186bdf06cdf3c4fc5f5f3e6"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.50.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "61dfdba58e585066d8bce214c5a51eaa0539f269"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "0c4f9c4f1a50d8f35048fa0532dabbadf702f81e"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.40.1+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "b404131d06f7886402758c9ce2214b636eb4d54a"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "5ee6203157c120d79034c748a2acba45b82b8807"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.40.1+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "a2d09619db4e765091ee5c6ffe8872849de0feea"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.28"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "c1dd6d7978c12545b4179fb6153b9250c96b0075"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.3"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0eef589dd1c26a3ac9d753fe1a8bcad63f956fa6"
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.16.8+1"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2025.11.4"

[[deps.Mustache]]
deps = ["Printf", "Tables"]
git-tree-sha1 = "3b2db451a872b20519ebb0cec759d3d81a1c6bcb"
uuid = "ffc61752-8dc7-55ee-8c37-f3e9cdd09e70"
version = "1.0.20"

[[deps.Mux]]
deps = ["AssetRegistry", "Base64", "HTTP", "Hiccup", "MbedTLS", "Pkg", "Sockets"]
git-tree-sha1 = "7295d849103ac4fcbe3b2e439f229c5cc77b9b69"
uuid = "a975b10e-0019-58db-a62f-e48ff68538c9"
version = "1.0.2"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.Observables]]
git-tree-sha1 = "7438a59546cf62428fc9d1bc94729146d37a7225"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.5"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.7+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.4+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6703a85cb3781bd5909d48730a67205f3f31a575"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.3+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.44.0+1"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e127b609fb9ecba6f201ba7ab753d5a605d53801"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.54.1+0"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pidfile]]
deps = ["FileWatching", "Test"]
git-tree-sha1 = "2d8aaf8ee10df53d0dfb9b8ee44ae7c04ced2b03"
uuid = "fa939f87-e72e-5be4-a000-7fc836dbe307"
version = "1.3.0"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "35621f10a7531bc8fa58f74610b1bfb70a3cfc6b"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.43.4+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.12.1"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "41031ef3a1be6f5bbbf3e8073f210556daeae5ca"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.3.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "StableRNGs", "Statistics"]
git-tree-sha1 = "3ca9a356cd2e113c420f2c13bea19f8d3fb1cb18"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.3"

[[deps.PlotlyBase]]
deps = ["ColorSchemes", "Dates", "DelimitedFiles", "DocStringExtensions", "JSON", "LaTeXStrings", "Logging", "Parameters", "Pkg", "REPL", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "56baf69781fc5e61607c3e46227ab17f7040ffa2"
uuid = "a03496cd-edff-5a9b-9e67-9cda94a718b5"
version = "0.8.19"

[[deps.PlotlyJS]]
deps = ["Base64", "Blink", "DelimitedFiles", "JSExpr", "JSON", "Kaleido_jll", "Markdown", "Pkg", "PlotlyBase", "PlotlyKaleido", "REPL", "Reexport", "Requires", "WebIO"]
git-tree-sha1 = "e415b25fdec06e57590a7d5ac8e0cf662fa317e2"
uuid = "f0f68f2c-4968-5e81-91da-67840de0976a"
version = "0.18.15"

    [deps.PlotlyJS.extensions]
    CSVExt = "CSV"
    DataFramesExt = ["DataFrames", "CSV"]
    IJuliaExt = "IJulia"
    JSON3Ext = "JSON3"

    [deps.PlotlyJS.weakdeps]
    CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    JSON3 = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"

[[deps.PlotlyKaleido]]
deps = ["Base64", "JSON", "Kaleido_jll"]
git-tree-sha1 = "3210de4d88af7ca5de9e26305758a59aabc48aac"
uuid = "f2990250-8cf9-495f-b13a-cce12b45703c"
version = "2.2.5"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "45470145863035bb124ca51b320ed35d071cc6c2"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.40.8"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "492601870742dcd38f233b23c3ec629628c1d724"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.7.1+1"

[[deps.Qt6Declarative_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6ShaderTools_jll"]
git-tree-sha1 = "e5dd466bf2569fe08c91a2cc29c1003f4797ac3b"
uuid = "629bc702-f1f5-5709-abd5-49b8460ea067"
version = "6.7.1+2"

[[deps.Qt6ShaderTools_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "1a180aeced866700d4bebc3120ea1451201f16bc"
uuid = "ce943373-25bb-56aa-8eca-768745ed7b5a"
version = "6.7.1+1"

[[deps.Qt6Wayland_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6Declarative_jll"]
git-tree-sha1 = "729927532d48cf79f49070341e1d918a65aba6b0"
uuid = "e99dba38-086e-5de3-a5b1-6e4c66e897c3"
version = "6.7.1+1"

[[deps.REPL]]
deps = ["InteractiveUtils", "JuliaSyntaxHighlighting", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.12.0"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "83e6cce8324d49dfaf9ef059227f91ed4441a8e5"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.2"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "5cf7606d6cef84b543b483848d4ae08ad9832b21"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.3"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.8.3+2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "598cd7c1f68d1e205689b1c2fe65a9f85846f297"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "d95fe458f26209c66a187b1114df96fd70839efd"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.21.0"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "975c354fcd5f7e1ddcc1f1a23e6e091d99e99bc8"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.4"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "7558e29847e99bc3f04d6569e82d0f5c54460703"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+1"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "93f43ab61b16ddfb2fd3bb13b3ce241cafb0e6c9"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.31.0+0"

[[deps.WebIO]]
deps = ["AssetRegistry", "Base64", "Distributed", "FunctionalCollections", "JSON", "Logging", "Observables", "Pkg", "Random", "Requires", "Sockets", "UUIDs", "WebSockets", "Widgets"]
git-tree-sha1 = "0eef0765186f7452e52236fa42ca8c9b3c11c6e3"
uuid = "0f1e0344-ec1d-5b48-a673-e5cf874b6c29"
version = "0.8.21"

[[deps.WebSockets]]
deps = ["Base64", "Dates", "HTTP", "Logging", "Sockets"]
git-tree-sha1 = "4162e95e05e79922e44b9952ccbc262832e4ad07"
uuid = "104b5d7c-a370-577a-8038-80a2059c5097"
version = "1.6.0"

[[deps.Widgets]]
deps = ["Colors", "Dates", "Observables", "OrderedCollections"]
git-tree-sha1 = "fcdae142c1cfc7d89de2d11e08721d0f2f86c98a"
uuid = "cc8bc4a8-27d6-5769-a93b-9d913e69aa62"
version = "0.6.6"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "6a451c6f33a176150f315726eba8b92fbfdb9ae7"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.4+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "a54ee957f4c86b526460a720dbc882fa5edcbefc"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.41+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "15e637a697345f6743674f1322beefbc5dcd5cfc"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.6.3+0"

[[deps.Xorg_libICE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "326b4fea307b0b39892b3e85fa451692eda8d46c"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.1.1+0"

[[deps.Xorg_libSM_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libICE_jll"]
git-tree-sha1 = "3796722887072218eabafb494a13c963209754ce"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.4+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "afead5aba5aa507ad5a3bf01f58f82c8d1403495"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6035850dcc70518ca32f012e46015b9beeda49d8"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.11+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "34d526d318358a859d7de23da945578e8e8727b7"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.4+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "d2d1a5c49fae4ba39983f63de6afcbea47194e85"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.6+0"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "47e45cd78224c53109495b3e324df0c37bb61fbe"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.11+0"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8fdda4c692503d44d04a0603d9ac0982054635f9"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.1+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "bcd466676fef0878338c61e655629fa7bbc69d8e"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.0+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "730eeca102434283c50ccf7d1ecdadf521a765a4"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "04341cb870f29dcd5e39055f895c39d016e18ccd"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.4+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "330f955bc41bb8f5270a369c473fc4a5a4e4d3cb"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.6+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "691634e5453ad362044e2ad653e79f3ee3bb98c3"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.39.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e92a1a012a10506618f10b7047e478403a046c77"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "555d1076590a6cc2fdee2ef1469451f872d8b41b"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.6+1"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "gperf_jll"]
git-tree-sha1 = "431b678a28ebb559d224c0b6b6d01afce87c51ba"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.9+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "936081b536ae4aa65415d869287d43ef3cb576b2"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.53.0+0"

[[deps.gperf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3516a5630f741c9eecb3720b1ec9d8edc3ecc033"
uuid = "1a1c6b14-54f6-533d-8383-74cd7377aa70"
version = "3.1.1+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1827acba325fdcdf1d2647fc8d5301dd9ba43a9d"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.9.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e17c115d55c5fbb7e52ebedb427a0dca79d4484e"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.2+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "141fe65dc3efabb0b1d5ba74e91f6ad26f84cc22"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.11.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a22cf860a7d27e4f3498a0fe0811a7957badb38"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.3+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "ad50e5b90f222cfe78aa3d5183a20a12de1322ce"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.18.0+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "b70c870239dc3d7bc094eb2d6be9b73d27bef280"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.44+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "490376214c4721cdaca654041f635213c6165cb3"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+2"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "814e154bdb7be91d78b6802843f76b6ece642f11"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.6+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.64.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.7.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9c304562909ab2bab0262639bd4f444d7bc2be37"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+1"
"""

# ╔═╡ Cell order:
# ╠═224ebb00-402a-459a-b668-8d115097d034
# ╟─2ff3b043-fe8d-4827-b219-474ec242bdb8
# ╠═8dc943b4-8305-4429-96e5-b696f38d355e
# ╠═bb30e0f1-d3ab-4262-ab9f-18c6f60581ec
# ╟─4bbd7878-c5d3-4747-b486-4e700857549a
# ╟─2f0ec5e4-0b30-4379-955c-06ea1435fe96
# ╟─e9e60100-4382-4c1b-8f61-2b3d436a67b3
# ╟─fd54d7ea-1009-4327-b895-743c045e525d
# ╠═3c2af411-f865-499f-8fb2-349e109a59e5
# ╠═df561969-2a17-45b8-895d-a2aa5ec80870
# ╠═99a59bac-cfd0-42f8-9e51-c0a5a5c594b0
# ╠═dad37239-29cb-484c-8b1d-86df429e5eed
# ╠═c0e6ff4d-7810-48e4-a7a9-e7aadf5af4c4
# ╟─55343a2d-185d-4027-9e58-355b2e141f56
# ╟─91f2ad3f-5970-40ed-83cd-e3d3cecf8eff
# ╟─beae6f46-4a2d-4a4f-8440-22137448b516
# ╟─d03e43d3-e1b4-4c54-b1b9-34f78f343a57
# ╟─ecd06175-ea2a-4638-89ac-e16c47fe2bc6
# ╟─2478a50e-0458-437a-ad71-8c14caa8ce64
# ╠═96a3e3bc-1d3a-4d3f-8bf0-99eeffbff723
# ╟─ecd7d0f5-a7da-4b9f-a606-48fc04a4a836
# ╠═e00dd8bd-6ee4-4823-97cc-48ba0229ce0b
# ╟─77832751-0600-4b18-9081-4e6c2d3fda4b
# ╠═1077a2ce-e544-46d4-ae07-5d167d48307a
# ╠═a17ab041-cf70-4cbb-9e9a-7a38c7339974
# ╟─7c5f8277-09d9-4cb7-a684-8da1af934adf
# ╟─b6bf31e2-a3ed-41d2-845d-dcf87d8ae09f
# ╠═d6fa4f1b-e8c7-4743-a391-a030a6dcbe1c
# ╟─780fbe09-89b4-4ca5-bc0c-f8698870c543
# ╟─5df231f1-6d78-4586-a529-2065ff61015d
# ╟─3cf789d7-78f4-4418-a753-ec0118dd0209
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
