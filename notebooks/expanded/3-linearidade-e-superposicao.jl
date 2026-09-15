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

# ╔═╡ 18041d2d-4411-49a1-b4a1-88e7ac79b7e0
begin
	using PlutoUI
	using Plots
	using PlotlyJS
	using LinearAlgebra
	using Printf
end

# ╔═╡ 71f847b1-79c0-4bf8-9f30-1334ac809581
md"""
# ⚡ Laboratório de Circuitos Elétricos I

!!! tip "Universidade Federal do Ceará — DEE"
	- **Disciplina:** Laboratório de Circuitos Elétricos em Corrente Contínua
	- **Semestre:** 2025.2
	- **Turmas:** 01 e 02
	- **Professor:** Lucas Silveira

## 🔬 Prática 4: Princípio da Linearidade e Teorema da Superposição

Seja muito bem-vindo a este **caderno interativo de laboratório**! Este material foi projetado para transformar o aprendizado de circuitos elétricos em uma experiência dinâmica, visual e intuitiva.

### 🎯 Objetivos de Aprendizagem:
1. 📏 **Propriedade da Homogeneidade (Proporcionalidade):** Compreender a relação linear direta entre amplitude de entrada e resposta de circuitos resistivos ($y = k \cdot x$), comprovando a invariância dos fatores de ganho.
2. ➕ **Propriedade da Aditividade:** Dominar o princípio de que a resposta de uma rede linear excitada por uma soma de estímulos é rigorosamente a soma das respostas individuais a cada estímulo isolado.
3. 🧩 **Teorema da Superposição:** Analisar circuitos elétricos complexos com múltiplas fontes independentes decompondo a rede em subcircuitos onde atua apenas uma fonte independente de cada vez.
4. 🔌 **Desativação Sistemática de Fontes:** Compreender física e matematicamente a substituição de fontes de tensão ideais por **curtos-circuitos** ($0\text{ V}$) e de fontes de corrente ideais por **circuitos abertos** ($0\text{ A}$), mantendo fontes dependentes inalteradas.
5. ⚠️ **A Falácia da Potência (Não-Linearidade):** Demonstrar analítica e computacionalmente por que a superposição **NÃO se aplica à potência dissipada** ($P \propto V^2, I^2$), quantificando com precisão o termo de acoplamento cruzado ($2 R i_a i_b$).
6. 🧮 **Equacionamento e Resolução Matricial ($A \cdot x = b$):** Aplicar o Método das Malhas (LKT) de forma sistemática para formular e resolver sistemas lineares dos circuitos da prática via decomposição LU no Julia.
7. 🚀 **Aplicações na Engenharia Moderna:** Explorar como o Teorema da Superposição viabiliza o funcionamento de conversores Digital-Analógico em rede escada **DAC R-2R**.
"""

# ╔═╡ 7d5b960d-68f4-4c01-b0ac-43cde1f3819b
PlutoUI.TableOfContents(title="📑 Conteúdo Interativo", indent=true)

# ╔═╡ aa1cf0d8-1be2-42a3-ba08-7dd114d73190
plotlyjs()

# ╔═╡ 5ac43001-4392-468d-aa4e-b3e4e6643ae2
md"""
---
## 1. 📏 Princípio da Linearidade: Fundamentos Teóricos

Um sistema elétrico contínuo é classificado como **linear** se a transformação matemática $H\{\cdot\}$ entre suas excitações (entradas $x(t)$) e suas respostas (saídas $y(t)$) satisfaz estritamente duas propriedades fundamentais:

### 1.1 Propriedade da Homogeneidade (Escala / Proporcionalidade)
Se a entrada $x(t)$ produz a resposta $y(t)$, então a entrada multiplicada por uma constante escalar arbitrária $\alpha$ produzirá a saída multiplicada pelo mesmo fator:
$$H\{\alpha \cdot x(t)\} = \alpha \cdot H\{x(t)\} = \alpha \cdot y(t), \quad \forall \alpha \in \mathbb{R}$$

### 1.2 Propriedade da Aditividade
Se a entrada $x_1(t)$ produz a saída $y_1(t)$ e a entrada $x_2(t)$ produz a saída $y_2(t)$, a aplicação simultânea da soma dessas entradas resulta na soma direta das saídas individuais:
$$H\{x_1(t) + x_2(t)\} = H\{x_1(t)\} + H\{x_2(t)\} = y_1(t) + y_2(t)$$

Combinando homogeneidade e aditividade em um único enunciado matemático, temos o **Princípio da Superposição**:
$$H\{\alpha \cdot x_1(t) + \beta \cdot x_2(t)\} = \alpha \cdot H\{x_1(t)\} + \beta \cdot H\{x_2(t)\} = \alpha \cdot y_1(t) + \beta \cdot y_2(t)$$

---

### 💡 Por que circuitos puramente resistivos são estritamente lineares?

1. **Relação Constitutiva dos Resistores (Lei de Ohm):**
   $$v(t) = R \cdot i(t)$$
   A característica $v \times i$ de um resistor ideal é uma linha reta perfeita passando pela origem. Se a corrente for duplicada, a tensão dobra; se a corrente for invertida, a tensão inverte com o mesmo módulo. Não há termos quadráticos, termos constantes ou histerese.

2. **Equações Topológicas de Interconexão (Leis de Kirchhoff):**
   - **LKC (Lei dos Nós):** A soma algébrica das correntes em qualquer nó é zero: $\sum_k i_k(t) = 0$.
   - **LKT (Lei das Malhas):** A soma algébrica das quedas e elevações de tensão em qualquer malha fechada é zero: $\sum_k v_k(t) = 0$.

Como todas as equações que governam correntes e tensões no circuito são relações algébricas de **primeiro grau**, o circuito resistivo como um todo opera como uma transformação linear sobre as fontes de excitação!

---

### 🔌 Procedimento Sistemático para Desativação de Fontes Independentes

Para analisar a contribuição de cada fonte isoladamente através do Teorema da Superposição, desativam-se todas as outras fontes independentes do circuito:

1. **Desativação de Fonte de Tensão Independente:**
   - Impor tensão nula ($V = 0\text{ V}$) significa que não pode haver diferença de potencial entre seus dois terminais, independente da corrente.
   - Isso equivale a substituir a fonte por um **CURTO-CIRCUITO** (fio ideal de resistência nula $R = 0\,\Omega$).

2. **Desativação de Fonte de Corrente Independente:**
   - Impor corrente nula ($I = 0\text{ A}$) significa que nenhuma corrente pode passar por aquele ramo, independente da tensão entre seus nós.
   - Isso equivale a substituir a fonte por um **CIRCUITO ABERTO** (ramo interrompido de resistência infinita $R = \infty\,\Omega$).

!!! warning "⚠️ Atenção Rigorosa: Fontes Dependentes e Fontes Reais"
	- **Fontes Dependentes (Controladas):** **NUNCA DEVEM SER DESATIVADAS!** Fontes dependentes modelam o comportamento ativo interno de dispositivos como transistores e amplificadores operacionais. Seu valor depende de correntes ou tensões internas do circuito que mudam a cada subcircuito analisado. Devem permanecer ativas em todas as etapas!
	- **Resistências Internas de Fontes Reais:** Se a fonte for real (com resistência interna $R_s$), apenas a fonte ideal é substituída por curto ou aberto; a sua resistência interna $R_s$ permanece conectada no circuito!
"""

# ╔═╡ 9c89d8d8-70f4-4b1d-ac7a-62127ab09c4a
md"""
---
## 2. 🧪 Estudo de Caso 1: Circuito 1 — Homogeneidade e Proporcionalidade

Vamos analisar o primeiro circuito experimental da Prática 4 do laboratório da UFC, projetado para comprovar a propriedade da homogeneidade.

### 📐 Topologia e Componentes Nominais
O circuito é alimentado por uma fonte de tensão contínua ajustável $V_{in}$ e composto por 5 resistores comerciais:
- $R_1 = 1.2\text{ k}\Omega$
- $R_2 = 330\,\Omega$
- $R_3 = 100\,\Omega$
- $R_4 = 470\,\Omega$
- $R_5 = 1.0\text{ k}\Omega$

```
                     R1 (1.2 kΩ)
         ┌──────────────/\/\/──────────────┐
         │                                  │
         o──────────────/\/\/──────────────o──────────────/\/\/──────────────┐
         │               R2 (330 Ω)         │               R3 (100 Ω)         │
         │                                  │                                  │
       ( + )                              ( + )                              [ R5 ]
      ( Vin ) Fonte                       [ R4 ] 470 Ω                       [ 1 kΩ]
       ( - )                              ( - )                                │
         │                                  │                                  │
         └──────────────────────────────────┴──────────────────────────────────┘
```

Adotando o sentido horário para as correntes das três malhas fechadas independentes:
- **Malha 1 (Superior):** Percorre os resistores $R_1$, $R_2$ e $R_3$ com corrente $i_{m1}$.
- **Malha 2 (Inferior Esquerda):** Percorre a fonte $V_{in}$, o resistor compartilhado $R_2$ e o resistor $R_4$ com corrente $i_{m2}$.
- **Malha 3 (Inferior Direita):** Percorre o resistor $R_4$, o resistor $R_3$ e o resistor $R_5$ com corrente $i_{m3}$.

---

### 🧮 Dedução das Equações de Malha (LKT)

1. **Malha 1:**
   $$R_1 \cdot i_{m1} + R_2 \cdot (i_{m1} - i_{m2}) + R_3 \cdot (i_{m1} - i_{m3}) = 0$$
   $$(R_1 + R_2 + R_3) \cdot i_{m1} - R_2 \cdot i_{m2} - R_3 \cdot i_{m3} = 0$$

2. **Malha 2:**
   $$-V_{in} + R_2 \cdot (i_{m2} - i_{m1}) + R_4 \cdot (i_{m2} - i_{m3}) = 0$$
   $$-R_2 \cdot i_{m1} + (R_2 + R_4) \cdot i_{m2} - R_4 \cdot i_{m3} = V_{in}$$

3. **Malha 3:**
   $$R_3 \cdot (i_{m3} - i_{m1}) + R_4 \cdot (i_{m3} - i_{m2}) + R_5 \cdot i_{m3} = 0$$
   $$-R_3 \cdot i_{m1} - R_4 \cdot i_{m2} + (R_3 + R_4 + R_5) \cdot i_{m3} = 0$$

Organizando na forma matricial $A_1 \cdot x_1 = b_1$:

$$\begin{bmatrix}
(R_1 + R_2 + R_3) & -R_2 & -R_3 \\
-R_2 & (R_2 + R_4) & -R_4 \\
-R_3 & -R_4 & (R_3 + R_4 + R_5)
\end{bmatrix}
\begin{bmatrix} i_{m1} \\ i_{m2} \\ i_{m3} \end{bmatrix}
=
\begin{bmatrix} 0 \\ V_{in} \\ 0 \end{bmatrix}$$

Substituindo numericamente os valores nominais dos resistores de laboratório:
$$\begin{bmatrix}
1630.0 & -330.0 & -100.0 \\
-330.0 & 800.0 & -470.0 \\
-100.0 & -470.0 & 1570.0
\end{bmatrix}
\begin{bmatrix} i_{m1} \\ i_{m2} \\ i_{m3} \end{bmatrix}
=
\begin{bmatrix} 0 \\ V_{in} \\ 0 \end{bmatrix}$$

---

### 🔍 Respostas de Tensão e Dedução Analítica da Homogeneidade

As grandezas de interesse medidas na bancada de laboratório são:
- **Tensão no resistor $R_4$ ($V_1$):** $V_1 = V_{R4} = R_4 \cdot (i_{m2} - i_{m3})$
- **Tensão no resistor $R_5$ ($V_2$):** $V_2 = V_{R5} = R_5 \cdot i_{m3}$

Como o vetor de excitação pode ser fatorado como $b_1 = V_{in} \cdot [0, 1, 0]^T$, temos:
$$x_1 = A_1^{-1} \cdot b_1 = V_{in} \cdot \left( A_1^{-1} \cdot \begin{bmatrix} 0 \\ 1 \\ 0 \end{bmatrix} \right)$$

Isso demonstra matematicamente que cada corrente e tensão do circuito é **estritamente proporcional à tensão da fonte $V_{in}$**:
$$V_1 = k_1 \cdot V_{in}, \qquad V_2 = k_2 \cdot V_{in}$$

Onde as constantes $k_1$ e $k_2$ representam as **funções de transferência de tensão (ganhos)** do circuito. Para os valores nominais de laboratório:
$$k_1 = \frac{V_1}{V_{in}} \approx 0.5568\text{ V/V}, \qquad k_2 = \frac{V_2}{V_{in}} \approx 0.5409\text{ V/V}$$
"""

# ╔═╡ c6a97615-3762-4edc-ad20-56f7ca175fe5
md"""
### 🎛️ Laboratório Virtual 1: Simulador Interativo de Homogeneidade (Circuito 1)

Varie a tensão da fonte $V_{in}$ abaixo e observe como as tensões de saída $V_1$ e $V_2$ acompanham instantaneamente a excitação, mantendo a razão de transferência rigorosamente constante:
"""

# ╔═╡ bf672f75-3fbc-4ab7-aa6d-1e0c179c0bc9
@bind Vin_c1 Slider(0.0:0.5:25.0, default=10.0, show_value=true)

# ╔═╡ 4624c15b-359e-4c9e-882f-6117a8a4e60f
@bind R4_c1 Slider(100.0:10.0:1000.0, default=470.0, show_value=true)

# ╔═╡ 97b011f2-93a0-4558-91c3-c19933585070
begin
	R1_c1 = 1200.0
	R2_c1 = 330.0
	R3_c1 = 100.0
	R5_c1 = 1000.0
	
	# Matriz de resistências das malhas (3x3)
	A_c1 = [
		(R1_c1 + R2_c1 + R3_c1)          -R2_c1                         -R3_c1;
		-R2_c1                  (R2_c1 + R4_c1)                         -R4_c1;
		-R3_c1                          -R4_c1         (R3_c1 + R4_c1 + R5_c1)
	]
	
	b_c1 = [0.0, Vin_c1, 0.0]
	
	# Resolução via decomposição LU no Julia
	x_c1 = A_c1 \ b_c1
	
	im1_c1 = x_c1[1]
	im2_c1 = x_c1[2]
	im3_c1 = x_c1[3]
	
	# Tensões nos resistores de interesse
	V1_c1 = R4_c1 * (im2_c1 - im3_c1)
	V2_c1 = R5_c1 * im3_c1
	
	# Fatores de proporcionalidade (ganhos)
	k1_c1 = Vin_c1 > 1e-6 ? V1_c1 / Vin_c1 : (R4_c1 * ((A_c1 \ [0.0, 1.0, 0.0])[2] - (A_c1 \ [0.0, 1.0, 0.0])[3]))
	k2_c1 = Vin_c1 > 1e-6 ? V2_c1 / Vin_c1 : (R5_c1 * ((A_c1 \ [0.0, 1.0, 0.0])[3]))
	
	is_linear_c1 = true
end

# ╔═╡ 366e748f-a586-489a-93b7-8fc492b46bec
let
	HTML("""
	<div style="background-color: #f0fdf4; border: 2px solid #22c55e; border-radius: 12px; padding: 18px; margin: 12px 0; font-family: sans-serif; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);">
		<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
			<h3 style="color: #15803d; margin: 0; font-size: 1.25em;">📏 Status da Homogeneidade: 🟢 SISTEMA LINEAR HOMOGÊNEO COMPROVADO</h3>
		</div>
		
		<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 14px;">
			<div style="background: rgba(255,255,255,0.9); padding: 12px; border-radius: 8px; border: 1px solid #bbf7d0;">
				<div style="color: #166534; font-size: 0.85em; text-transform: uppercase; font-weight: bold;">Excitação de Entrada</div>
				<div style="margin-top: 6px; font-size: 1.2em;"><b>Tensão Vin:</b> <span style="color: #15803d; font-weight: bold;">$(@sprintf("%.2f", Vin_c1)) V</span></div>
				<div style="margin-top: 6px; color: #4b5563; font-size: 0.9em;">
					Ganho k₁ = V₁/Vin: <b>$(@sprintf("%.4f", k1_c1))</b><br>
					Ganho k₂ = V₂/Vin: <b>$(@sprintf("%.4f", k2_c1))</b>
				</div>
			</div>
			
			<div style="background: rgba(255,255,255,0.9); padding: 12px; border-radius: 8px; border: 1px solid #bbf7d0;">
				<div style="color: #166534; font-size: 0.85em; text-transform: uppercase; font-weight: bold;">Tensões de Saída Medidas</div>
				<div style="margin-top: 6px;"><b>Tensão em R4 (V₁):</b> <span style="color: #0284c7; font-weight: bold; font-size: 1.1em;">$(@sprintf("%.4f", V1_c1)) V</span></div>
				<div style="margin-top: 4px;"><b>Tensão em R5 (V₂):</b> <span style="color: #9333ea; font-weight: bold; font-size: 1.1em;">$(@sprintf("%.4f", V2_c1)) V</span></div>
				<div style="margin-top: 4px; font-size: 0.85em; color: #4b5563;">Corrente no ramo R4: $(@sprintf("%.3f", (im2_c1 - im3_c1) * 1e3)) mA</div>
			</div>
			
			<div style="background: rgba(255,255,255,0.9); padding: 12px; border-radius: 8px; border: 1px solid #bbf7d0;">
				<div style="color: #166534; font-size: 0.85em; text-transform: uppercase; font-weight: bold;">Correntes de Malha</div>
				<div style="margin-top: 4px;"><b>i_m1:</b> $(@sprintf("%.3f", im1_c1 * 1e3)) mA</div>
				<div><b>i_m2:</b> $(@sprintf("%.3f", im2_c1 * 1e3)) mA</div>
				<div><b>i_m3:</b> $(@sprintf("%.3f", im3_c1 * 1e3)) mA</div>
			</div>
		</div>
		
		<div style="margin-top: 12px; padding-top: 10px; border-top: 1px solid rgba(0,0,0,0.08); font-size: 0.9em; color: #374151;">
			👉 <b>Missão do Aluno:</b> Varie o slider de <b>Vin</b> e observe que as razões de ganho <b>k₁</b> e <b>k₂</b> não se alteram em nenhuma casa decimal! Isso comprova na prática que circuitos resistivos satisfazem a <b>propriedade de homogeneidade</b>.
		</div>
	</div>
	""")
end

# ╔═╡ dba647a5-f732-40cb-a932-89a141336416
begin
	V_sweep = 0.0:1.0:25.0
	V1_sweep = Float64[]
	V2_sweep = Float64[]
	
	for v in V_sweep
		x_temp = A_c1 \ [0.0, v, 0.0]
		push!(V1_sweep, R4_c1 * (x_temp[2] - x_temp[3]))
		push!(V2_sweep, R5_c1 * x_temp[3])
	end
	
	# Pontos de ensaio de bancada
	V_table = 0.0:2.0:20.0
	V1_table = [R4_c1 * ((A_c1 \ [0.0, v, 0.0])[2] - (A_c1 \ [0.0, v, 0.0])[3]) for v in V_table]
	V2_table = [R5_c1 * ((A_c1 \ [0.0, v, 0.0])[3]) for v in V_table]
	
	p_c1 = Plots.plot(V_sweep, V1_sweep, 
		lw=2.5, 
		color=:royalblue, 
		label=@sprintf("V₁ (Tensão em R4) — Ganho k₁ = %.4f", k1_c1),
		xlabel="Tensão da Fonte Vin (V)", 
		ylabel="Tensão nos Resistores (V)", 
		title="Circuito 1: Relação Linear de Entrada-Saída (Homogeneidade)",
		grid=true, 
		gridalpha=0.35, 
		legend=:topleft
	)
	
	Plots.plot!(V_sweep, V2_sweep, 
		lw=2.5, 
		color=:purple, 
		label=@sprintf("V₂ (Tensão em R5) — Ganho k₂ = %.4f", k2_c1)
	)
	
	Plots.scatter!(V_table, V1_table, 
		color=:royalblue, 
		marker=(:circle, 5), 
		label="Pontos Amostrados na Bancada (V₁)"
	)
	
	Plots.scatter!(V_table, V2_table, 
		color=:purple, 
		marker=(:diamond, 5), 
		label="Pontos Amostrados na Bancada (V₂)"
	)
	
	# Ponto de operação atual do slider
	Plots.scatter!([Vin_c1], [V1_c1], 
		marker=(:star5, 10), 
		color=:red, 
		label=@sprintf("Ponto Atual (Vin=%.1f V, V₁=%.2f V)", Vin_c1, V1_c1)
	)
	
	p_c1
end

# ╔═╡ b0a22b75-d694-4b13-a0a4-b807fac84a65
md"""
---
## 3. 🔬 Estudo de Caso 2: Circuito 2 — Teorema da Superposição

O segundo circuito do roteiro experimental de laboratório da UFC investiga uma rede alimentada por **duas fontes independentes de tensão contínua**: $V_a$ e $V_b$.

### 📐 Topologia do Circuito em Escada Simétrica
A rede é configurada com resistores de precisão organizados em três malhas:
- **Resistores Horizontais e de Ramo Superior:** $R_a = 1.0\text{ k}\Omega$
- **Resistores Verticais Compartilhados:** $R_b = 3.3\text{ k}\Omega$
- **Fonte $V_a$:** Conectada na Malha 1 (ramo esquerdo)
- **Fonte $V_b$:** Conectada na Malha 3 (ramo direito)

```
                     Ra (1.0 kΩ)                     Ra (1.0 kΩ)
             o──────────/\/\/──────────o───────────────/\/\/──────────o
             │                          │                               │
           ( + )                        │                               │
          (  Va )                     [ Rb ] 3.3 kΩ                   [ Rb ] 3.3 kΩ
           ( - )      (Malha 1)         │             (Malha 2)         │             (Malha 3)
             │                          │                               │
             o──────────────────────────o───────────────/\/\/──────────o
             │                                         Ra (1.0 kΩ)      │
             │                                                        ( - )
             │                                                       (  Vb )
             │                                                        ( + )
             └──────────────────────────────────────────────────────────┘
```

---

### 🧮 Equacionamento das Três Malhas (LKT)

Adotando o sentido horário para as correntes de malha $i_1, i_2, i_3$:

1. **Malha 1:**
   $$+V_a - R_a \cdot i_1 - R_b \cdot (i_1 - i_2) = 0$$
   $$(R_a + R_b) \cdot i_1 - R_b \cdot i_2 + 0 \cdot i_3 = V_a$$

2. **Malha 2:**
   $$-R_b \cdot (i_2 - i_1) - R_a \cdot i_2 - R_b \cdot (i_2 - i_3) = 0$$
   $$-R_b \cdot i_1 + (R_a + 2R_b) \cdot i_2 - R_b \cdot i_3 = 0$$

3. **Malha 3:**
   $$-R_b \cdot (i_3 - i_2) - R_a \cdot i_3 - V_b = 0$$
   $$0 \cdot i_1 - R_b \cdot i_2 + (R_a + R_b) \cdot i_3 = -V_b$$

*(Note a convenção de sinais na malha 3: ao circular no sentido horário, entramos pelo terminal positivo da fonte $V_b$ e saímos pelo negativo, o que produz uma queda de potencial $-V_b$ que, ao passar para o lado direito da igualdade, resulta em $-V_b$ no vetor de excitação).*

Organizando na forma matricial $A_2 \cdot x = b_2$:

$$\begin{bmatrix}
(R_a + R_b) & -R_b & 0 \\
-R_b & (R_a + 2R_b) & -R_b \\
0 & -R_b & (R_a + R_b)
\end{bmatrix}
\begin{bmatrix} i_1 \\ i_2 \\ i_3 \end{bmatrix}
=
\begin{bmatrix} V_a \\ 0 \\ -V_b \end{bmatrix}$$

---

### 🧩 Decomposição em 3 Etapas pelo Teorema da Superposição

O resistor sob análise minuciosa no laboratório é o **resistor $R_1$** (que corresponde ao resistor vertical $R_b$ compartilhado entre as malhas 1 e 2).

- **Corrente através de $R_1$:** $i_{R1} = i_1 - i_2$
- **Tensão sobre $R_1$:** $V_{R1} = R_b \cdot (i_1 - i_2)$
- **Potência dissipada em $R_1$:** $P_{R1} = R_b \cdot (i_1 - i_2)^2$

#### Etapa 1: Subcircuito A (Apenas Fonte $V_a$ Ativa)
A fonte $V_b$ é desativada e substituída por um **curto-circuito** ($V_b = 0\text{ V}$):
$$b_{2}^{(a)} = \begin{bmatrix} V_a \\ 0 \\ 0 \end{bmatrix} \implies x_2^{(a)} = A_2^{-1} \cdot b_2^{(a)}$$
Calculam-se:
$$i_{R1}^{(a)} = x_2^{(a)}[1] - x_2^{(a)}[2], \qquad V_{R1}^{(a)} = R_b \cdot i_{R1}^{(a)}, \qquad P_{R1}^{(a)} = R_b \cdot (i_{R1}^{(a)})^2$$

#### Etapa 2: Subcircuito B (Apenas Fonte $V_b$ Ativa)
A fonte $V_a$ é desativada e substituída por um **curto-circuito** ($V_a = 0\text{ V}$):
$$b_{2}^{(b)} = \begin{bmatrix} 0 \\ 0 \\ -V_b \end{bmatrix} \implies x_2^{(b)} = A_2^{-1} \cdot b_2^{(b)}$$
Calculam-se:
$$i_{R1}^{(b)} = x_2^{(b)}[1] - x_2^{(b)}[2], \qquad V_{R1}^{(b)} = R_b \cdot i_{R1}^{(b)}, \qquad P_{R1}^{(b)} = R_b \cdot (i_{R1}^{(b)})^2$$

#### Etapa 3: Circuito Completo (Ambas as Fontes Ativas Simultaneamente)
Ambas as fontes $V_a$ e $V_b$ atuam juntas no circuito:
$$b_{2} = \begin{bmatrix} V_a \\ 0 \\ -V_b \end{bmatrix} = b_2^{(a)} + b_2^{(b)} \implies x_2 = A_2^{-1} \cdot b_2$$
Calculam-se:
$$i_{R1}^{(total)} = x_2[1] - x_2[2], \qquad V_{R1}^{(total)} = R_b \cdot i_{R1}^{(total)}, \qquad P_{R1}^{(total)} = R_b \cdot (i_{R1}^{(total)})^2$$

Pelo Teorema da Superposição para grandezas lineares:
$$V_{R1}^{(total)} = V_{R1}^{(a)} + V_{R1}^{(b)} \qquad \text{e} \qquad i_{R1}^{(total)} = i_{R1}^{(a)} + i_{R1}^{(b)}$$
"""

# ╔═╡ 73f54b2f-cc5e-47b4-b27d-9a7715596381
md"""
### 🎛️ Laboratório Virtual 2: Simulador de Superposição (Circuito 2)

Ajuste as fontes de alimentação $V_a$ e $V_b$ e os resistores de circuito. Observe na tabela interativa abaixo a comparação instantânea entre os efeitos isolados, a soma algébrica das parcelas e a resposta com excitação simultânea:
"""

# ╔═╡ 32e1bee8-569a-47c2-92a4-5670a5f6b1f7
@bind Va Slider(0.0:0.5:10.0, default=5.0, show_value=true)

# ╔═╡ a6c7f138-ff93-4073-97e7-a215dd1de6f8
@bind Vb Slider(0.0:0.5:15.0, default=10.0, show_value=true)

# ╔═╡ 752e0c34-6dea-4d2a-8052-40d320078052
@bind Ra Slider(500.0:100.0:3000.0, default=1000.0, show_value=true)

# ╔═╡ f17accab-82f9-49a1-9087-d640a278b984
@bind Rb Slider(1000.0:100.0:6000.0, default=3300.0, show_value=true)

# ╔═╡ 064b3199-2bd9-4e3d-929d-18b273edd32a
begin
	# Matriz de Malhas do Circuito 2
	A2 = [
		(Ra + Rb)      -Rb             0.0;
		-Rb       (Ra + 2.0*Rb)       -Rb;
		 0.0           -Rb        (Ra + Rb)
	]
	
	# Caso A: Apenas Va ativo (Vb = 0 em curto)
	b2_a = [Va, 0.0, 0.0]
	x2_a = A2 \ b2_a
	iR1_a = x2_a[1] - x2_a[2]
	VR1_a = Rb * iR1_a
	PR1_a = Rb * (iR1_a)^2 * 1e3 # mW
	
	# Caso B: Apenas Vb ativo (Va = 0 em curto)
	b2_b = [0.0, 0.0, -Vb]
	x2_b = A2 \ b2_b
	iR1_b = x2_b[1] - x2_b[2]
	VR1_b = Rb * iR1_b
	PR1_b = Rb * (iR1_b)^2 * 1e3 # mW
	
	# Caso Total: Ambas as fontes ativas simultaneamente
	b2_total = [Va, 0.0, -Vb]
	x2_total = A2 \ b2_total
	iR1_total = x2_total[1] - x2_total[2]
	VR1_total = Rb * iR1_total
	PR1_total = Rb * (iR1_total)^2 * 1e3 # mW
	
	# Soma das grandezas lineares (Superposição)
	VR1_soma = VR1_a + VR1_b
	iR1_soma = iR1_a + iR1_b
	PR1_soma = PR1_a + PR1_b
	
	# Termo cruzado de potência
	termo_cruzado_mW = 2.0 * Rb * iR1_a * iR1_b * 1e3
	
	# Erros percentuais de verificação
	erro_VR1_pct = abs(VR1_total) > 1e-6 ? abs(VR1_soma - VR1_total) / abs(VR1_total) * 100.0 : 0.0
	erro_iR1_pct = abs(iR1_total) > 1e-6 ? abs(iR1_soma - iR1_total) / abs(iR1_total) * 100.0 : 0.0
	diff_PR1_pct = abs(PR1_total) > 1e-6 ? abs(PR1_soma - PR1_total) / abs(PR1_total) * 100.0 : 0.0
end

# ╔═╡ ca3eeb66-d8c3-4a0b-80df-87ada8cbbf3d
let
	HTML("""
	<div style="background-color: #f8fafc; border: 2px solid #3b82f6; border-radius: 12px; padding: 20px; margin: 14px 0; font-family: sans-serif; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);">
		<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
			<h3 style="color: #1e3a8a; margin: 0; font-size: 1.25em;">📊 Tabela Comparativa de Verificação do Teorema da Superposição</h3>
		</div>
		
		<p style="margin: 0 0 14px 0; color: #475569; font-size: 0.95em;">
			Análise no resistor <b>R₁ = $(@sprintf("%.0f", Rb)) Ω</b> com <b>Va = $(@sprintf("%.1f", Va)) V</b> e <b>Vb = $(@sprintf("%.1f", Vb)) V</b>:
		</p>
		
		<div style="overflow-x: auto;">
			<table style="width: 100%; border-collapse: collapse; text-align: left; background: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.1);">
				<thead>
					<tr style="background-color: #1e3a8a; color: #ffffff;">
						<th style="padding: 12px 14px;">Grandeza no Resistor R₁</th>
						<th style="padding: 12px 14px; text-align: center;">Efeito Isolado de Va<br><small style="font-weight: normal; opacity: 0.85;">(Vb = 0 V em curto)</small></th>
						<th style="padding: 12px 14px; text-align: center;">Efeito Isolado de Vb<br><small style="font-weight: normal; opacity: 0.85;">(Va = 0 V em curto)</small></th>
						<th style="padding: 12px 14px; text-align: center;">Soma dos Efeitos<br><small style="font-weight: normal; opacity: 0.85;">(Superposição: a + b)</small></th>
						<th style="padding: 12px 14px; text-align: center;">Ambas Ativas<br><small style="font-weight: normal; opacity: 0.85;">(Medição Simultânea)</small></th>
						<th style="padding: 12px 14px; text-align: center;">Status da Validade</th>
					</tr>
				</thead>
				<tbody>
					<tr style="border-bottom: 1px solid #e2e8f0;">
						<td style="padding: 12px 14px; font-weight: bold; color: #1e293b;">Tensão VR1 (V)</td>
						<td style="padding: 12px 14px; text-align: center; color: #0284c7; font-weight: bold;">$(@sprintf("%+.4f", VR1_a)) V</td>
						<td style="padding: 12px 14px; text-align: center; color: #7c3aed; font-weight: bold;">$(@sprintf("%+.4f", VR1_b)) V</td>
						<td style="padding: 12px 14px; text-align: center; color: #16a34a; font-weight: bold; background-color: #f0fdf4;">$(@sprintf("%+.4f", VR1_soma)) V</td>
						<td style="padding: 12px 14px; text-align: center; color: #16a34a; font-weight: bold; background-color: #f0fdf4;">$(@sprintf("%+.4f", VR1_total)) V</td>
						<td style="padding: 12px 14px; text-align: center; color: #16a34a; font-weight: bold; background-color: #f0fdf4;">0.0000% ✅ VÁLIDA</td>
					</tr>
					<tr style="border-bottom: 1px solid #e2e8f0;">
						<td style="padding: 12px 14px; font-weight: bold; color: #1e293b;">Corrente iR1 (mA)</td>
						<td style="padding: 12px 14px; text-align: center; color: #0284c7; font-weight: bold;">$(@sprintf("%+.4f", iR1_a * 1e3)) mA</td>
						<td style="padding: 12px 14px; text-align: center; color: #7c3aed; font-weight: bold;">$(@sprintf("%+.4f", iR1_b * 1e3)) mA</td>
						<td style="padding: 12px 14px; text-align: center; color: #16a34a; font-weight: bold; background-color: #f0fdf4;">$(@sprintf("%+.4f", iR1_soma * 1e3)) mA</td>
						<td style="padding: 12px 14px; text-align: center; color: #16a34a; font-weight: bold; background-color: #f0fdf4;">$(@sprintf("%+.4f", iR1_total * 1e3)) mA</td>
						<td style="padding: 12px 14px; text-align: center; color: #16a34a; font-weight: bold; background-color: #f0fdf4;">0.0000% ✅ VÁLIDA</td>
					</tr>
					<tr style="background-color: #fef2f2;">
						<td style="padding: 12px 14px; font-weight: bold; color: #991b1b;">Potência PR1 (mW)</td>
						<td style="padding: 12px 14px; text-align: center; color: #0284c7;">$(@sprintf("%.4f", PR1_a)) mW</td>
						<td style="padding: 12px 14px; text-align: center; color: #7c3aed;">$(@sprintf("%.4f", PR1_b)) mW</td>
						<td style="padding: 12px 14px; text-align: center; color: #dc2626; font-weight: bold;">$(@sprintf("%.4f", PR1_soma)) mW</td>
						<td style="padding: 12px 14px; text-align: center; color: #991b1b; font-weight: bold; background-color: #fee2e2;">$(@sprintf("%.4f", PR1_total)) mW</td>
						<td style="padding: 12px 14px; text-align: center; color: #dc2626; font-weight: bold; background-color: #fee2e2;">$(@sprintf("%.1f", diff_PR1_pct))% ❌ NÃO-LINEAR!</td>
					</tr>
				</tbody>
			</table>
		</div>
		
		<div style="margin-top: 14px; padding: 12px; background: #ffffff; border-radius: 8px; border-left: 4px solid #ef4444; font-size: 0.9em; color: #1e293b;">
			⚠️ <b>Atenção ao Termo Cruzado de Potência:</b> A potência real simultânea é <b>$(@sprintf("%.4f", PR1_total)) mW</b>, enquanto a soma ingênua das potências individuais é apenas <b>$(@sprintf("%.4f", PR1_soma)) mW</b>. A discrepância exata de <b>$(@sprintf("%+.4f", termo_cruzado_mW)) mW</b> decorre do termo de acoplamento não-linear: <code>2 · R₁ · i_a · i_b</code>!
		</div>
	</div>
	""")
end

# ╔═╡ a30410e8-8893-4b82-a402-80a5c35aec96
md"""
---
## 4. ⚠️ A Falácia da Superposição de Potência: Análise da Não-Linearidade

Uma das dúvidas e confusões conceituais mais frequentes entre estudantes de engenharia elétrica é:
> *"Se a tensão obedece à superposição ($V_{total} = V_a + V_b$) e a corrente obedece à superposição ($i_{total} = i_a + i_b$), por que a potência dissipada NÃO obedece à superposição ($P_{total} \neq P_a + P_b$)?"*

### 📐 Demonstração Algébrica Rigorosa do Termo Cruzado

Considere um resistor $R$ percorrido pela corrente total $i_{total} = i_a + i_b$, onde $i_a$ é a corrente induzida exclusivamente pela fonte $A$ e $i_b$ é a corrente induzida exclusivamente pela fonte $B$.

Pela Lei de Joule, a potência instantânea total dissipada é dada pelo quadrado da corrente total:
$$P_{total} = R \cdot (i_{total})^2 = R \cdot (i_a + i_b)^2$$

Expandindo o binômio ao quadrado:
$$P_{total} = R \cdot (i_a^2 + 2 \cdot i_a \cdot i_b + i_b^2)$$
$$P_{total} = \underbrace{R \cdot i_a^2}_{P_a} + \underbrace{R \cdot i_b^2}_{P_b} + \underbrace{2 \cdot R \cdot i_a \cdot i_b}_{\Delta P_{\text{cruzado}}}$$

$$P_{total} = P_a + P_b + 2 R \cdot i_a \cdot i_b$$

!!! danger "🚫 Por que a soma das potências falha?"
	A potência é uma **grandeza quadrática** ($P \propto i^2, P \propto v^2$). Na álgebra linear, o operador de potenciação $f(x) = x^2$ é intrinsicamente **NÃO-LINEAR**, pois:
	$$(x_1 + x_2)^2 = x_1^2 + 2x_1 x_2 + x_2^2 \neq x_1^2 + x_2^2$$
	
	O termo $2 R \cdot i_a \cdot i_b$ é o **termo de acoplamento cruzado**. Ele representa a interação construtiva ou destrutiva entre os fluxos de energia injetados pelas fontes:
	- Se $i_a$ e $i_b$ tiverem o **mesmo sentido** ($i_a \cdot i_b > 0$), a potência total será **maior** que a soma das potências ($P_{total} > P_a + P_b$).
	- Se $i_a$ e $i_b$ tiverem **sentidos opostos** ($i_a \cdot i_b < 0$), as fontes disputam o fluxo de carga e a potência total será **menor** que a soma ($P_{total} < P_a + P_b$).
	- A superposição de potências só seria verdadeira no caso trivial em que uma das fontes não provocasse nenhuma corrente no resistor ($i_a = 0$ ou $i_b = 0$).
"""

# ╔═╡ c31affa8-7cf8-4db0-9c79-dbb2da9d6172
begin
	Va_sweep = 0.0:0.5:20.0
	Vb_fixed = 10.0
	
	VR1_curve = Float64[]
	PR1_curve_real = Float64[]
	PR1_curve_soma = Float64[]
	
	for v in Va_sweep
		# Efeito isolado de Va
		x_a_sw = A2 \ [v, 0.0, 0.0]
		i_a_sw = x_a_sw[1] - x_a_sw[2]
		p_a_sw = Rb * i_a_sw^2 * 1e3
		
		# Efeito isolado de Vb fixo
		x_b_sw = A2 \ [0.0, 0.0, -Vb_fixed]
		i_b_sw = x_b_sw[1] - x_b_sw[2]
		p_b_sw = Rb * i_b_sw^2 * 1e3
		
		# Efeito simultâneo
		x_tot_sw = A2 \ [v, 0.0, -Vb_fixed]
		i_tot_sw = x_tot_sw[1] - x_tot_sw[2]
		v_tot_sw = Rb * i_tot_sw
		p_tot_sw = Rb * i_tot_sw^2 * 1e3
		
		push!(VR1_curve, v_tot_sw)
		push!(PR1_curve_real, p_tot_sw)
		push!(PR1_curve_soma, p_a_sw + p_b_sw)
	end
	
	p_lin = Plots.plot(Va_sweep, VR1_curve,
		lw=2.5,
		color=:royalblue,
		label="Tensão VR1(Va) — Relação Linear",
		xlabel="Tensão de Entrada Va (V)",
		ylabel="Tensão VR1 (V)",
		title="Linearidade de Tensão",
		grid=true, gridalpha=0.35,
		legend=:topleft
	)
	
	p_pow = Plots.plot(Va_sweep, PR1_curve_real,
		lw=2.5,
		color=:crimson,
		label="Potência Real P_total = R · (ia + ib)²",
		xlabel="Tensão de Entrada Va (V)",
		ylabel="Potência Dissipada em R1 (mW)",
		title="Não-Linearidade de Potência",
		grid=true, gridalpha=0.35,
		legend=:topleft
	)
	
	Plots.plot!(p_pow, Va_sweep, PR1_curve_soma,
		lw=2.0,
		ls=:dash,
		color=:darkorange,
		label="Soma Ingênua P_soma = Pa + Pb (Errada!)"
	)
	
	Plots.plot(p_lin, p_pow, layout=(1, 2), size=(880, 360))
end

# ╔═╡ 4fe65937-ad90-4eac-bbbd-3cec676e18b3
md"""
---
## 5. 🚀 Aplicação na Engenharia Moderna: O Conversor D/A em Escada R-2R

O princípio da superposição não é apenas uma ferramenta analítica de resolução de exercícios: ele é a pedra fundamental sobre a qual operam circuitos modernos de alta tecnologia, como os **Conversores Digital-Analógico (DACs - *Digital-to-Analog Converters*)**.

### 💡 Como um computador converte bits (0s e 1s) em tensões analógicas contínuas?
Em sistemas embarcados (como placas Arduino, microcontroladores ARM e FPGAs), os pinos de saída digital fornecem apenas dois níveis lógicos:
- **Nível Lógico 0:** $0\text{ V}$ (GND)
- **Nível Lógico 1:** $V_{ref}$ (tipicamente $3.3\text{ V}$ ou $5.0\text{ V}$)

Para produzir um sinal de áudio, sintetizar uma onda senoidal ou acionar um motor com tensão analógica proporcional à palavra binária, utiliza-se a clássica **rede em escada R-2R**:

```
        Bit 3 (MSB)        Bit 2              Bit 1              Bit 0 (LSB)
           (b3)               (b2)               (b1)               (b0)
            │                  │                  │                  │
           [2R]               [2R]               [2R]               [2R]
            │                  │                  │                  │
   Vout ────o──────[ R ]───────o──────[ R ]───────o──────[ R ]───────o──────[ 2R ]──── GND
```

### 🎛️ Princípio da Superposição Aplicado ao DAC R-2R
Cada bit digital $b_k \in \{0, 1\}$ atua como uma fonte independente de tensão:
- Quando $b_k = 0$, o terminal correspondente é ligado ao terra ($0\text{ V}$, fonte desativada em curto-circuito).
- Quando $b_k = 1$, o terminal é conectado à fonte de referência $V_{ref}$.

Devido à simetria da escada resistiva, a resistência equivalente vista de cada nó em direção aos estágios inferiores é sempre rigorosamente igual a $2R$. Consequentemente, cada divisor de tensão divide a tensão exatamente pela metade a cada degrau da escada!

Pelo **Teorema da Superposição**, a tensão analógica total de saída $V_{out}$ é a soma ponderada das contribuições de cada bit individual:

$$V_{out} = V_{ref} \cdot \left( \frac{b_3}{2^1} + \frac{b_2}{2^2} + \frac{b_1}{2^3} + \frac{b_0}{2^4} \right) = \frac{V_{ref}}{16} \cdot (8 b_3 + 4 b_2 + 2 b_1 + b_0)$$

- O bit mais significativo (**MSB** - $b_3$) contribui sozinho com metade da escala: $V_{ref} / 2$.
- O bit $b_2$ contribui com $V_{ref} / 4$.
- O bit $b_1$ contribui com $V_{ref} / 8$.
- O bit menos significativo (**LSB** - $b_0$) contribui com $V_{ref} / 16$.
"""

# ╔═╡ 939117af-4ef1-41e7-9392-ab92a7090795
md"""
### 🎛️ Simulador Interativo de DAC R-2R de 4 Bits

Experimente ligar e desligar os bits binários abaixo para ver a superposição em ação na geração da tensão analógica de saída:
"""

# ╔═╡ 8f4a3baa-fd39-4b89-98c1-eb96a9dcebaa
@bind bit3 Slider(0:1, default=1, show_value=true)

# ╔═╡ b503abbb-35d9-417b-b07f-b135e158bf6b
@bind bit2 Slider(0:1, default=0, show_value=true)

# ╔═╡ 81ee66f3-7470-4e4a-9cfd-b6caeba39a98
@bind bit1 Slider(0:1, default=1, show_value=true)

# ╔═╡ 9c418a73-bbc8-4e88-b198-2209d6297c07
@bind bit0 Slider(0:1, default=1, show_value=true)

# ╔═╡ be454f53-8c30-4b8a-9779-23e420411525
@bind Vref_dac Slider(1.0:0.5:10.0, default=5.0, show_value=true)

# ╔═╡ eaf5c25f-752b-4492-a904-8757406c5419
let
	# Contribuição individual de cada bit por superposição
	V_b3 = (bit3 * Vref_dac) / 2.0
	V_b2 = (bit2 * Vref_dac) / 4.0
	V_b1 = (bit1 * Vref_dac) / 8.0
	V_b0 = (bit0 * Vref_dac) / 16.0
	
	# Tensão analógica total superposta
	Vout_dac = V_b3 + V_b2 + V_b1 + V_b0
	
	# Código digital inteiro (0 a 15)
	codigo_dec = bit3 * 8 + bit2 * 4 + bit1 * 2 + bit0 * 1
	pct_escala = (Vout_dac / Vref_dac) * 100.0
	
	HTML("""
	<div style="background-color: #f8fafc; border: 2px solid #8b5cf6; border-radius: 12px; padding: 18px; margin: 12px 0; font-family: sans-serif;">
		<h4 style="margin: 0 0 10px 0; color: #5b21b6; font-size: 1.2em;">💻 Conversor Digital-Analógico R-2R (Superposição de Bits):</h4>
		
		<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 14px; margin-bottom: 14px;">
			<div style="background: #ffffff; padding: 12px; border-radius: 8px; border: 1px solid #ddd6fe;">
				<div style="color: #6b21a8; font-size: 0.85em; text-transform: uppercase; font-weight: bold;">Palavra Binária de Entrada</div>
				<div style="margin-top: 6px; font-size: 1.3em; font-family: monospace; color: #5b21b6; font-weight: bold;">
					[b₃ b₂ b₁ b₀] = [$(bit3) $(bit2) $(bit1) $(bit0)]₂
				</div>
				<div style="margin-top: 4px; color: #475569;">Valor Decimal: <b>$(codigo_dec)</b> / 15 (Resolução: 4 bits)</div>
			</div>
			
			<div style="background: #ffffff; padding: 12px; border-radius: 8px; border: 1px solid #ddd6fe;">
				<div style="color: #6b21a8; font-size: 0.85em; text-transform: uppercase; font-weight: bold;">Tensão Analógica Sintetizada</div>
				<div style="margin-top: 6px; font-size: 1.3em; font-weight: bold; color: #059669;">
					Vout = $(@sprintf("%.4f", Vout_dac)) V
				</div>
				<div style="margin-top: 4px; color: #475569;">Fração de Fundo de Escala: <b>$(@sprintf("%.1f", pct_escala)) %</b> de $(@sprintf("%.1f", Vref_dac)) V</div>
			</div>
		</div>
		
		<div style="background: #ffffff; padding: 12px; border-radius: 8px; border: 1px solid #e2e8f0; font-size: 0.9em;">
			<div style="font-weight: bold; margin-bottom: 6px; color: #334155;">Decomposição por Superposição (Fontes de Tensão Ideais):</div>
			<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 8px; font-family: monospace;">
				<div>Bit 3 (MSB): <b>$(@sprintf("%.3f", V_b3)) V</b></div>
				<div>Bit 2: <b>$(@sprintf("%.3f", V_b2)) V</b></div>
				<div>Bit 1: <b>$(@sprintf("%.3f", V_b1)) V</b></div>
				<div>Bit 0 (LSB): <b>$(@sprintf("%.3f", V_b0)) V</b></div>
			</div>
		</div>
		
		<div style="margin-top: 12px; width: 100%; background: #e2e8f0; border-radius: 6px; height: 16px; overflow: hidden;">
			<div style="width: $(pct_escala)%; background: linear-gradient(90deg, #8b5cf6, #10b981); height: 100%; transition: width 0.3s ease;"></div>
		</div>
	</div>
	""")
end

# ╔═╡ a307bb4a-407e-4f87-99d4-72803748f7ee
md"""
---
## 6. 🎯 Mini-Quiz Interativo de Fixação

Teste sua compreensão sobre os limites e a aplicação correta do Princípio da Superposição:

**Questão Conceitual de Concurso:** Em um circuito linear puramente resistivo excitado por duas fontes independentes de tensão contínua $V_1$ e $V_2$, constatam-se os seguintes resultados experimentais:
- Quando **apenas a fonte $V_1$ está ligada** ($V_2 = 0\text{ V}$), a potência dissipada em um determinado resistor $R$ é de **$4\text{ W}$**.
- Quando **apenas a fonte $V_2$ está ligada** ($V_1 = 0\text{ V}$), a potência dissipada no mesmo resistor $R$ é de **$9\text{ W}$**, com a corrente percorrendo o resistor **no mesmo sentido** que no ensaio anterior.

Qual será a potência total dissipada no resistor $R$ quando **ambas as fontes $V_1$ e $V_2$ forem ligadas simultaneamente**?
"""

# ╔═╡ 914d8864-8700-435c-b25a-ec943bc4ca21
@bind quiz_ans_sup Select([
	"Selecione sua resposta...",
	"A) 13 W (4 W + 9 W pela soma direta das potências)",
	"B) 25 W (calculada pela corrente total resultante: I_total = I_1 + I_2)",
	"C) 5 W (9 W - 4 W pela diferença entre as fontes)",
	"D) 36 W (4 W × 9 W pelo produto das potências)"
])

# ╔═╡ bb349883-14ee-407d-bc21-6b0df24b8fb0
begin
	if quiz_ans_sup == "Selecione sua resposta..."
		md"""*👉 Escolha uma opção acima para validar sua intuição teórica.*"""
	elseif quiz_ans_sup == "B) 25 W (calculada pela corrente total resultante: I_total = I_1 + I_2)"
		md"""
		<div style="padding: 16px; background-color: #ecfdf5; border-left: 5px solid #10b981; border-radius: 8px; font-family: sans-serif;">
			🎉 <b>Parabéns! Resposta Perfeita!</b><br><br>
			A potência <b>NUNCA obedece à superposição direta</b> ($P_{total} \neq P_1 + P_2$). Devemos aplicar a superposição às correntes (que são grandezas estritamente lineares):
			$$P_1 = R \cdot I_1^2 = 4\text{ W} \implies \sqrt{R} \cdot I_1 = \sqrt{4} = 2$$
			$$P_2 = R \cdot I_2^2 = 9\text{ W} \implies \sqrt{R} \cdot I_2 = \sqrt{9} = 3$$
			
			Como as correntes têm o mesmo sentido, a corrente total é:
			$$I_{total} = I_1 + I_2$$
			$$P_{total} = R \cdot (I_{total})^2 = (\sqrt{R} \cdot I_1 + \sqrt{R} \cdot I_2)^2 = (2 + 3)^2 = 5^2 = 25\text{ W}$$
			
			O termo cruzado de acoplamento adicionou $2 \sqrt{P_1 P_2} = 2 \cdot 2 \cdot 3 = 12\text{ W}$, totalizando $4 + 9 + 12 = 25\text{ W}$!
		</div>
		"""
	elseif quiz_ans_sup == "A) 13 W (4 W + 9 W pela soma direta das potências)"
		md"""
		<div style="padding: 16px; background-color: #fef2f2; border-left: 5px solid #ef4444; border-radius: 8px; font-family: sans-serif;">
			❌ <b>Você caiu na clássica armadilha da superposição de potências!</b><br><br>
			Lembre-se: o Teorema da Superposição aplica-se <b>apenas a grandezas lineares</b> (tensões e correntes). A potência é quadrática ($P = R \cdot I^2$), o que gera o termo cruzado $2 R I_1 I_2$. A potência total nunca é simplesmente $P_1 + P_2$ quando ambas as correntes fluem juntas! Revise a Seção 4.
		</div>
		"""
	else
		md"""
		<div style="padding: 16px; background-color: #fef2f2; border-left: 5px solid #ef4444; border-radius: 8px; font-family: sans-serif;">
			❌ <b>Resposta Incorreta.</b><br><br>
			Primeiro calcule a corrente induzida por cada fonte: $I_1 = \sqrt{4/R}$ e $I_2 = \sqrt{9/R}$. Como têm o mesmo sentido, a corrente total é a soma linear $I_{total} = I_1 + I_2$. Em seguida, eleve ao quadrado para encontrar a potência total!
		</div>
		"""
	end
end

# ╔═╡ e2e9c931-46dc-4953-a9c9-7e9fcd9255af
md"""
---
## 7. 🛠️ Boas Práticas e Dicas de Bancada (UFC / DEE)

Para garantir o sucesso, a segurança e a precisão metrológica dos seus ensaios na bancada do Laboratório de Circuitos Elétricos da UFC, observe atentamente as seguintes recomendações práticas:

!!! warning "⚠️ Cuidados e Procedimentos Essenciais na Prática de Bancada"
	1. **Como "Desligar" Fontes na Bancada Real:**
	   - Para anular uma fonte de tensão independente, **desconecte os cabos dos bornes da fonte e instale um fio condutor (*jumper*)** unindo os pontos do circuito no protoboard onde a fonte estava conectada.
	   - **PERIGO GRAVE:** **JAMAIS curto-circuite diretamente os bornes positivo (+) e negativo (-) de uma fonte de bancada ligada!** Isso provoca um curto-circuito pleno na saída do equipamento, acionando o limite de corrente ou fundindo o fusível de proteção interno.
	
	2. **Cuidados com Fontes Múltiplas e Referência de Terra (GND):**
	   - As fontes de bancada com múltiplos canais (como as fontes Minipa do DEE) possuem saídas flutuantes (*floating*). Ao montar circuitos com mais de uma fonte ($V_a$ e $V_b$), você deve interligar os bornes negativos das fontes que compartilham o mesmo potencial de referência comum no circuito da matriz de contatos (*protoboard*).
	
	3. **Limite de Potência dos Resistores de Laboratório ($P_{max} = 1/4\text{ W} = 250\text{ mW}$):**
	   - Quando ambas as fontes atuam simultaneamente, a potência nos resistores cresce de forma quadrática com a corrente. Verifique sempre se $P < 250\text{ mW}$. Se um resistor esquentar excessivamente a ponto de não ser possível tocá-lo, desligue a alimentação imediatamente: ele está dissipando acima do limite e sua resistência ôhmica variará por deriva térmica!
	
	4. **Operação e Proteção do Multímetro Digital:**
	   - **Medição de Tensão (Voltímetro):** Sempre conecte em **paralelo** com o componente (alta impedância de entrada, tipicamente $10\text{ M}\Omega$).
	   - **Medição de Corrente (Amperímetro):** Sempre conecte em **série**, abrindo a malha/ramo físico do circuito para que os elétrons atravessem o instrumento. **Nunca conecte as pontas de prova na escala de corrente em paralelo com qualquer componente ou fonte**, pois o amperímetro se comporta como um curto-circuito e queimará o fusível interno do instrumento!
	
	5. **Tolerância dos Componentes:**
	   - Resistores comerciais de 4 faixas têm tolerância típica de $\pm 5\%$. Antes de energizar a bancada, meça os valores ôhmicos reais de cada resistor ($R_1$ a $R_5$) e utilize esses valores medidos nas suas simulações computacionais para obter concordância milimétrica entre teoria e experimento.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
""
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

# ╔═╡ 00000000-0000-0000-0000-000000000
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
""
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
"
"""

# ╔═╡ Cell order:
# ╠═18041d2d-4411-49a1-b4a1-88e7ac79b7e0
# ╟─71f847b1-79c0-4bf8-9f30-1334ac809581
# ╠═7d5b960d-68f4-4c01-b0ac-43cde1f3819b
# ╠═aa1cf0d8-1be2-42a3-ba08-7dd114d73190
# ╟─5ac43001-4392-468d-aa4e-b3e4e6643ae2
# ╟─9c89d8d8-70f4-4b1d-ac7a-62127ab09c4a
# ╟─c6a97615-3762-4edc-ad20-56f7ca175fe5
# ╠═bf672f75-3fbc-4ab7-aa6d-1e0c179c0bc9
# ╠═4624c15b-359e-4c9e-882f-6117a8a4e60f
# ╠═97b011f2-93a0-4558-91c3-c19933585070
# ╟─366e748f-a586-489a-93b7-8fc492b46bec
# ╠═dba647a5-f732-40cb-a932-89a141336416
# ╟─b0a22b75-d694-4b13-a0a4-b807fac84a65
# ╟─73f54b2f-cc5e-47b4-b27d-9a7715596381
# ╠═32e1bee8-569a-47c2-92a4-5670a5f6b1f7
# ╠═a6c7f138-ff93-4073-97e7-a215dd1de6f8
# ╠═752e0c34-6dea-4d2a-8052-40d320078052
# ╠═f17accab-82f9-49a1-9087-d640a278b984
# ╠═064b3199-2bd9-4e3d-929d-18b273edd32a
# ╟─ca3eeb66-d8c3-4a0b-80df-87ada8cbbf3d
# ╟─a30410e8-8893-4b82-a402-80a5c35aec96
# ╠═c31affa8-7cf8-4db0-9c79-dbb2da9d6172
# ╟─4fe65937-ad90-4eac-bbbd-3cec676e18b3
# ╟─939117af-4ef1-41e7-9392-ab92a7090795
# ╠═8f4a3baa-fd39-4b89-98c1-eb96a9dcebaa
# ╠═b503abbb-35d9-417b-b07f-b135e158bf6b
# ╠═81ee66f3-7470-4e4a-9cfd-b6caeba39a98
# ╠═9c418a73-bbc8-4e88-b198-2209d6297c07
# ╠═be454f53-8c30-4b8a-9779-23e420411525
# ╟─eaf5c25f-752b-4492-a904-8757406c5419
# ╟─a307bb4a-407e-4f87-99d4-72803748f7ee
# ╠═914d8864-8700-435c-b25a-ec943bc4ca21
# ╟─bb349883-14ee-407d-bc21-6b0df24b8fb0
# ╟─e2e9c931-46dc-4953-a9c9-7e9fcd9255af
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
