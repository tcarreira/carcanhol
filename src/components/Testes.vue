<template>
  <div class="container mx-auto p-4">
    <!-- Formulário de Input -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4 mb-6">
      <div class="form-group">
        <label class="block mb-2">Montante Inicial (€)</label>
        <input type="number" v-model.number="initialAmount" class="border p-2 w-full rounded" />
      </div>
      <div class="form-group">
        <label class="block mb-2">Taxa de Juro Anual (%)</label>
        <input type="number" v-model.number="interestRate" class="border p-2 w-full rounded" />
      </div>
      <div class="form-group">
        <label class="block mb-2">Reforço Mensal (€)</label>
        <input type="number" v-model.number="monthlyContribution" class="border p-2 w-full rounded" />
      </div>
      <div class="form-group">
        <label class="block mb-2">Número de Anos</label>
        <input type="number" v-model.number="years" class="border p-2 w-full rounded" />
      </div>
      <div class="form-group">
        <button @click="calculate" class="bg-blue-500 text-white px-4 py-2 rounded mt-6">
          Calcular
        </button>
      </div>
    </div>

    <!-- Tabela de Resultados -->
    <div class="overflow-x-auto mb-6">
      <table class="min-w-full bg-white">
        <thead>
          <tr>
            <th class="border p-2">Ano</th>
            <th class="border p-2">Capital Inicial</th>
            <th class="border p-2">Reforços Anuais</th>
            <th class="border p-2">Juros</th>
            <th class="border p-2">Total</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, index) in results" :key="index">
            <td class="border p-2">{{ row.year }}</td>
            <td class="border p-2">{{ formatCurrency(row.initialCapital) }}</td>
            <td class="border p-2">{{ formatCurrency(row.contributions) }}</td>
            <td class="border p-2">{{ formatCurrency(row.interest) }}</td>
            <td class="border p-2">{{ formatCurrency(row.total) }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Gráfico -->
    <div class="w-full h-96">
      <LineChart
        :data="chartData"
        :options="chartOptions"
      />
    </div>
  </div>
</template>

<script>
import { Line as LineChart } from 'vue-chartjs'
import { Chart as ChartJS, CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend } from 'chart.js'

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend)

export default {
  name: 'CompoundInterestCalculator',
  components: {
    LineChart
  },
  data() {
    return {
      initialAmount: 1000,
      interestRate: 5,
      monthlyContribution: 100,
      years: 10,
      results: [],
      chartData: {
        labels: [],
        datasets: []
      },
      chartOptions: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'top',
          },
          title: {
            display: true,
            text: 'Evolução do Investimento'
          }
        }
      }
    }
  },
  methods: {
    calculate() {
      this.results = []
      let totalContributions = this.initialAmount
      let currentAmount = this.initialAmount
      const monthlyRate = this.interestRate / 100 / 12
      const monthlyContribution = this.monthlyContribution

      for (let year = 1; year <= this.years; year++) {
        let yearlyContributions = monthlyContribution * 12
        let startYearAmount = currentAmount

        // Cálculo mensal dos juros compostos
        for (let month = 1; month <= 12; month++) {
          currentAmount = (currentAmount + monthlyContribution) * (1 + monthlyRate)
        }

        totalContributions += yearlyContributions

        this.results.push({
          year,
          initialCapital: startYearAmount,
          contributions: yearlyContributions,
          interest: currentAmount - totalContributions,
          total: currentAmount
        })
      }

      this.updateChart()
    },
    updateChart() {
      this.chartData = {
        labels: this.results.map(r => `Ano ${r.year}`),
        datasets: [
          {
            label: 'Capital Total',
            backgroundColor: 'rgba(54, 162, 235, 0.2)',
            borderColor: 'rgb(54, 162, 235)',
            data: this.results.map(r => r.total)
          },
          {
            label: 'Capital Investido',
            backgroundColor: 'rgba(75, 192, 192, 0.2)',
            borderColor: 'rgb(75, 192, 192)',
            data: this.results.map(r => r.initialCapital + r.contributions)
          }
        ]
      }
    },
    formatCurrency(value) {
      return new Intl.NumberFormat('pt-PT', {
        style: 'currency',
        currency: 'EUR'
      }).format(value)
    }
  }
}
</script>
